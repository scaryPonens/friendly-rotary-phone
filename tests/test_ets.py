from friendly_rotary_phone.algorithms import (
    primitive_attachment,
    reconcile_partial_orders,
    single_level_substruct,
)
from friendly_rotary_phone.ets import (
    ActiveConstraint,
    ETSStruct,
    Primitive,
    StructGeneratingMachine,
    apply_constraint,
)
from friendly_rotary_phone.examples import (
    bubble_man_machine,
    bubble_man_spatial_program,
    generate_bubble_man,
)
from friendly_rotary_phone.graphviz import machine_to_dot


def test_apply_constraint_adds_primitives_and_links():
    struct = ETSStruct()
    constraint = ActiveConstraint(
        id="c1",
        required_labels=["head", "torso"],
        required_links=[("head", "torso")],
    )

    apply_constraint(struct, constraint)

    labels = {p.label for p in struct.primitives.values()}
    assert labels == {"head", "torso"}
    assert len(struct.links) == 1


def test_struct_generating_machine_rejects_invalid_transition():
    machine = StructGeneratingMachine(
        start_state="q0",
        accept_states={"q1"},
        transitions={},
        emissions={},
    )

    try:
        machine.generate(ETSStruct(), class_representation=None, events=["step"])  # type: ignore[arg-type]
    except Exception as exc:  # noqa: BLE001
        assert "invalid transition" in str(exc)


def test_bubble_man_generation_and_trace():
    struct, state, trace = generate_bubble_man()

    assert state == "q3"
    assert trace == ["seed_head", "grow_torso", "attach_limbs"]
    labels = sorted(p.label for p in struct.primitives.values())
    assert labels == ["head", "left_arm", "right_arm", "torso"]


def test_bubble_man_spatial_program():
    program, final_state = bubble_man_spatial_program()
    assert final_state == "s4"
    assert program[:2] == ["spawn_head", "render"]
    assert "attach_right_arm" in program


def test_graphviz_export_contains_transitions():
    dot = machine_to_dot(bubble_man_machine(), graph_name="bubble_man")
    assert "digraph bubble_man" in dot
    assert '"q0" -> "q1" [label="step / seed_head"]' in dot


def test_primitive_attachment_and_substruct_algorithms():
    struct = ETSStruct()
    struct.add_primitive(Primitive(id="head-1", label="head"))

    primitive_attachment(struct, "head-1", Primitive(id="torso-1", label="torso"), "out")
    primitive_attachment(struct, "torso-1", Primitive(id="arm-1", label="left_arm"), "out")

    sub = single_level_substruct(struct, ["head-1"])
    assert set(sub.primitives) == {"head-1", "torso-1"}


def test_reconcile_partial_orders():
    assert reconcile_partial_orders([("a", "b"), ("b", "c")]) is True
    assert reconcile_partial_orders([("a", "b"), ("b", "a")]) is False
