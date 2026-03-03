from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any


PrimitiveId = str
Label = str
Link = tuple[PrimitiveId, PrimitiveId]


@dataclass(slots=True)
class Primitive:
    id: PrimitiveId
    label: Label
    metadata: dict[str, Any] = field(default_factory=dict)


@dataclass(slots=True)
class ETSStruct:
    primitives: dict[PrimitiveId, Primitive] = field(default_factory=dict)
    links: set[Link] = field(default_factory=set)

    def add_primitive(self, primitive: Primitive) -> None:
        self.primitives[primitive.id] = primitive

    def has_primitive(self, primitive_id: PrimitiveId) -> bool:
        return primitive_id in self.primitives

    def add_link(self, source_id: PrimitiveId, target_id: PrimitiveId) -> None:
        if source_id not in self.primitives:
            raise KeyError(f"missing source primitive: {source_id}")
        if target_id not in self.primitives:
            raise KeyError(f"missing target primitive: {target_id}")
        self.links.add((source_id, target_id))

    def primitive_ids_with_label(self, label: Label) -> list[PrimitiveId]:
        return [pid for pid, primitive in self.primitives.items() if primitive.label == label]

    def edge_list(self) -> list[Link]:
        return sorted(self.links)


@dataclass(slots=True)
class ActiveConstraint:
    id: str
    required_labels: list[Label]
    required_links: list[tuple[Label, Label]] = field(default_factory=list)
    anchor_labels: list[Label] = field(default_factory=list)
    open_labels: list[Label] = field(default_factory=list)


def apply_constraint(struct: ETSStruct, constraint: ActiveConstraint) -> ETSStruct:
    """
    Minimal thesis-inspired active extension.

    Ensures required labels exist in the struct and then applies required links
    by label.
    """

    label_to_id: dict[Label, PrimitiveId] = {}

    for label in constraint.required_labels:
        existing_ids = struct.primitive_ids_with_label(label)
        if existing_ids:
            label_to_id[label] = existing_ids[0]
            continue

        new_id = f"{label}-{len(struct.primitives) + 1}"
        struct.add_primitive(Primitive(id=new_id, label=label))
        label_to_id[label] = new_id

    for source_label, target_label in constraint.required_links:
        struct.add_link(label_to_id[source_label], label_to_id[target_label])

    return struct


@dataclass(slots=True)
class ClassRepresentation:
    constraints: dict[str, ActiveConstraint]

    @classmethod
    def from_constraints(cls, constraints: list[ActiveConstraint]) -> "ClassRepresentation":
        return cls({constraint.id: constraint for constraint in constraints})

    def get(self, constraint_id: str) -> ActiveConstraint:
        try:
            return self.constraints[constraint_id]
        except KeyError as exc:
            raise KeyError(f"missing constraint: {constraint_id}") from exc


@dataclass(slots=True)
class StructGeneratingMachine:
    start_state: str
    accept_states: set[str]
    transitions: dict[tuple[str, str], str]
    emissions: dict[tuple[str, str], str]

    def generate(
        self,
        initial_struct: ETSStruct,
        class_representation: ClassRepresentation,
        events: list[str],
    ) -> tuple[ETSStruct, str, list[str]]:
        current_state = self.start_state
        struct = initial_struct
        trace: list[str] = []

        for event in events:
            transition_key = (current_state, event)
            if transition_key not in self.transitions:
                raise ValueError(f"invalid transition: {current_state} --{event}--> ?")

            next_state = self.transitions[transition_key]
            constraint_id = self.emissions.get(transition_key)
            if constraint_id is not None:
                constraint = class_representation.get(constraint_id)
                apply_constraint(struct, constraint)
                trace.append(constraint_id)

            current_state = next_state

        if current_state not in self.accept_states:
            raise ValueError(f"non-accepting final state: {current_state}")

        return struct, current_state, trace


@dataclass(slots=True)
class Transducer:
    start_state: str
    transitions: dict[tuple[str, Label], str]
    emissions: dict[tuple[str, Label], list[str]]

    def run(self, labels: list[Label]) -> tuple[list[str], str]:
        current_state = self.start_state
        program: list[str] = []

        for label in labels:
            key = (current_state, label)
            if key not in self.transitions:
                raise ValueError(f"invalid transducer transition: {current_state} --{label}--> ?")

            program.extend(self.emissions.get(key, []))
            current_state = self.transitions[key]

        return program, current_state
