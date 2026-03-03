from __future__ import annotations

from friendly_rotary_phone.ets import (
    ActiveConstraint,
    ClassRepresentation,
    ETSStruct,
    StructGeneratingMachine,
    Transducer,
)


def bubble_man_class_representation() -> ClassRepresentation:
    return ClassRepresentation.from_constraints(
        [
            ActiveConstraint(id="seed_head", required_labels=["head"]),
            ActiveConstraint(
                id="grow_torso",
                required_labels=["head", "torso"],
                required_links=[("head", "torso")],
            ),
            ActiveConstraint(
                id="attach_limbs",
                required_labels=["torso", "left_arm", "right_arm"],
                required_links=[("torso", "left_arm"), ("torso", "right_arm")],
            ),
        ]
    )


def bubble_man_machine() -> StructGeneratingMachine:
    return StructGeneratingMachine(
        start_state="q0",
        accept_states={"q3"},
        transitions={
            ("q0", "step"): "q1",
            ("q1", "step"): "q2",
            ("q2", "step"): "q3",
        },
        emissions={
            ("q0", "step"): "seed_head",
            ("q1", "step"): "grow_torso",
            ("q2", "step"): "attach_limbs",
        },
    )


def generate_bubble_man() -> tuple[ETSStruct, str, list[str]]:
    machine = bubble_man_machine()
    return machine.generate(
        initial_struct=ETSStruct(),
        class_representation=bubble_man_class_representation(),
        events=["step", "step", "step"],
    )


def bubble_man_transducer() -> Transducer:
    return Transducer(
        start_state="s0",
        transitions={
            ("s0", "head"): "s1",
            ("s1", "torso"): "s2",
            ("s2", "left_arm"): "s3",
            ("s3", "right_arm"): "s4",
        },
        emissions={
            ("s0", "head"): ["spawn_head", "render"],
            ("s1", "torso"): ["grow_torso", "render"],
            ("s2", "left_arm"): ["attach_left_arm", "render"],
            ("s3", "right_arm"): ["attach_right_arm", "render"],
        },
    )


def bubble_man_spatial_program() -> tuple[list[str], str]:
    struct, _state, _trace = generate_bubble_man()
    desired_order = ["head", "torso", "left_arm", "right_arm"]
    labels = sorted(
        [primitive.label for primitive in struct.primitives.values()],
        key=lambda label: desired_order.index(label) if label in desired_order else 999,
    )
    return bubble_man_transducer().run(labels)
