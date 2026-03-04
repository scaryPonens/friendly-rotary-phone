from friendly_rotary_phone.examples import (
    bubble_man_class_representation,
    bubble_man_machine,
    generate_bubble_man,
)
from friendly_rotary_phone.io import (
    class_representation_from_dict,
    class_representation_to_dict,
    machine_from_dict,
    machine_to_dict,
    struct_from_dict,
    struct_to_dict,
)
from friendly_rotary_phone.visualization import machine_to_networkx, struct_to_networkx


def test_struct_json_roundtrip():
    struct, _state, _trace = generate_bubble_man()

    data = struct_to_dict(struct)
    restored = struct_from_dict(data)

    assert set(struct.primitives) == set(restored.primitives)
    assert struct.links == restored.links


def test_machine_json_roundtrip():
    machine = bubble_man_machine()
    data = machine_to_dict(machine)
    restored = machine_from_dict(data)

    assert machine.start_state == restored.start_state
    assert machine.accept_states == restored.accept_states
    assert machine.transitions == restored.transitions
    assert machine.emissions == restored.emissions


def test_class_representation_json_roundtrip():
    class_rep = bubble_man_class_representation()
    data = class_representation_to_dict(class_rep)
    restored = class_representation_from_dict(data)

    assert set(class_rep.constraints) == set(restored.constraints)


def test_networkx_export_helpers():
    struct, _state, _trace = generate_bubble_man()
    struct_graph = struct_to_networkx(struct)
    machine_graph = machine_to_networkx(bubble_man_machine())

    assert struct_graph.number_of_nodes() == len(struct.primitives)
    assert struct_graph.number_of_edges() == len(struct.links)
    assert machine_graph.number_of_nodes() >= 4
    assert machine_graph.number_of_edges() >= 3
