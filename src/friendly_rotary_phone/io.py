from __future__ import annotations

from dataclasses import asdict
from typing import Any

from friendly_rotary_phone.ets import (
    ActiveConstraint,
    ClassRepresentation,
    ETSStruct,
    Primitive,
    StructGeneratingMachine,
)


SCHEMA_VERSION = "ets-json-v1"


def struct_to_dict(struct: ETSStruct) -> dict[str, Any]:
    return {
        "schema": SCHEMA_VERSION,
        "kind": "struct",
        "primitives": [asdict(p) for p in struct.primitives.values()],
        "links": [[source, target] for source, target in sorted(struct.links)],
    }


def struct_from_dict(data: dict[str, Any]) -> ETSStruct:
    _validate_kind(data, "struct")

    struct = ETSStruct()
    for primitive in data.get("primitives", []):
        struct.add_primitive(
            Primitive(
                id=primitive["id"],
                label=primitive["label"],
                metadata=primitive.get("metadata", {}),
            )
        )

    for source_id, target_id in data.get("links", []):
        struct.add_link(source_id, target_id)

    return struct


def machine_to_dict(machine: StructGeneratingMachine) -> dict[str, Any]:
    transitions = [
        {"from": source_state, "event": event, "to": target_state}
        for (source_state, event), target_state in sorted(machine.transitions.items())
    ]

    emissions = [
        {"state": source_state, "event": event, "constraint": constraint_id}
        for (source_state, event), constraint_id in sorted(machine.emissions.items())
    ]

    return {
        "schema": SCHEMA_VERSION,
        "kind": "machine",
        "start_state": machine.start_state,
        "accept_states": sorted(machine.accept_states),
        "transitions": transitions,
        "emissions": emissions,
    }


def machine_from_dict(data: dict[str, Any]) -> StructGeneratingMachine:
    _validate_kind(data, "machine")

    transitions = {
        (item["from"], item["event"]): item["to"] for item in data.get("transitions", [])
    }
    emissions = {
        (item["state"], item["event"]): item["constraint"] for item in data.get("emissions", [])
    }

    return StructGeneratingMachine(
        start_state=data["start_state"],
        accept_states=set(data.get("accept_states", [])),
        transitions=transitions,
        emissions=emissions,
    )


def class_representation_to_dict(class_representation: ClassRepresentation) -> dict[str, Any]:
    constraints = []
    for constraint in class_representation.constraints.values():
        constraints.append(
            {
                "id": constraint.id,
                "required_labels": constraint.required_labels,
                "required_links": [list(link) for link in constraint.required_links],
                "anchor_labels": constraint.anchor_labels,
                "open_labels": constraint.open_labels,
            }
        )

    return {
        "schema": SCHEMA_VERSION,
        "kind": "class_representation",
        "constraints": constraints,
    }


def class_representation_from_dict(data: dict[str, Any]) -> ClassRepresentation:
    _validate_kind(data, "class_representation")

    constraints = [
        ActiveConstraint(
            id=item["id"],
            required_labels=item.get("required_labels", []),
            required_links=[(source, target) for source, target in item.get("required_links", [])],
            anchor_labels=item.get("anchor_labels", []),
            open_labels=item.get("open_labels", []),
        )
        for item in data.get("constraints", [])
    ]

    return ClassRepresentation.from_constraints(constraints)


def _validate_kind(data: dict[str, Any], expected_kind: str) -> None:
    schema = data.get("schema")
    if schema != SCHEMA_VERSION:
        raise ValueError(f"unsupported schema: {schema}; expected {SCHEMA_VERSION}")

    kind = data.get("kind")
    if kind != expected_kind:
        raise ValueError(f"invalid kind: {kind}; expected {expected_kind}")
