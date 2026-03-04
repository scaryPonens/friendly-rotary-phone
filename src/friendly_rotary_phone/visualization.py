from __future__ import annotations

import networkx as nx

from friendly_rotary_phone.ets import ETSStruct, StructGeneratingMachine


def struct_to_networkx(struct: ETSStruct) -> nx.DiGraph:
    graph = nx.DiGraph()

    for primitive_id, primitive in struct.primitives.items():
        graph.add_node(
            primitive_id,
            label=primitive.label,
            metadata=primitive.metadata,
        )

    for source_id, target_id in struct.links:
        graph.add_edge(source_id, target_id)

    return graph


def machine_to_networkx(machine: StructGeneratingMachine) -> nx.DiGraph:
    graph = nx.DiGraph()

    graph.add_node(machine.start_state, role="start")
    for state in machine.accept_states:
        graph.add_node(state, role="accept")

    for (source_state, event), target_state in machine.transitions.items():
        emission = machine.emissions.get((source_state, event))
        graph.add_edge(
            source_state,
            target_state,
            event=event,
            emission=emission,
            label=f"{event}" + (f" / {emission}" if emission else ""),
        )

    return graph
