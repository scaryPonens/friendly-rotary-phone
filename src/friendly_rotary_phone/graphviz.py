from __future__ import annotations

from friendly_rotary_phone.ets import StructGeneratingMachine


def machine_to_dot(machine: StructGeneratingMachine, graph_name: str = "ets_machine") -> str:
    lines = [
        f"digraph {graph_name} {{",
        "  rankdir=LR;",
        "  node [shape=circle];",
        "  start [shape=point];",
        f'  start -> "{machine.start_state}";',
    ]

    for state in sorted(machine.accept_states):
        lines.append(f'  "{state}" [shape=doublecircle];')

    for (source_state, event), target_state in sorted(machine.transitions.items()):
        emission = machine.emissions.get((source_state, event))
        label = f"{event} / {emission}" if emission else event
        lines.append(f'  "{source_state}" -> "{target_state}" [label="{label}"];')

    lines.append("}")
    return "\n".join(lines)
