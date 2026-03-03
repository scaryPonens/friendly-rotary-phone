from __future__ import annotations

from dataclasses import dataclass, field


@dataclass(slots=True)
class Primitive:
    id: str
    label: str
    metadata: dict = field(default_factory=dict)


@dataclass(slots=True)
class ETSStruct:
    primitives: dict[str, Primitive] = field(default_factory=dict)
    links: set[tuple[str, str]] = field(default_factory=set)

    def add_primitive(self, primitive: Primitive) -> None:
        self.primitives[primitive.id] = primitive

    def add_link(self, source_id: str, target_id: str) -> None:
        if source_id not in self.primitives:
            raise KeyError(f"missing source primitive: {source_id}")
        if target_id not in self.primitives:
            raise KeyError(f"missing target primitive: {target_id}")
        self.links.add((source_id, target_id))


@dataclass(slots=True)
class ActiveConstraint:
    required_labels: list[str]
    required_links: list[tuple[str, str]] = field(default_factory=list)


def apply_constraint(struct: ETSStruct, constraint: ActiveConstraint) -> ETSStruct:
    label_to_id: dict[str, str] = {}

    for label in constraint.required_labels:
        existing = next((pid for pid, p in struct.primitives.items() if p.label == label), None)
        if existing is None:
            new_id = f"{label}-{len(struct.primitives) + 1}"
            struct.add_primitive(Primitive(id=new_id, label=label))
            label_to_id[label] = new_id
        else:
            label_to_id[label] = existing

    for source_label, target_label in constraint.required_links:
        struct.add_link(label_to_id[source_label], label_to_id[target_label])

    return struct
