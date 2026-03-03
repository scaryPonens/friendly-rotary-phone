from __future__ import annotations

from collections import deque

from friendly_rotary_phone.ets import ETSStruct, Primitive


def struct_link(struct: ETSStruct, source_id: str, target_id: str) -> ETSStruct:
    struct.add_link(source_id, target_id)
    return struct


def primitive_attachment(
    struct: ETSStruct,
    pivot_id: str,
    new_primitive: Primitive,
    direction: str,
) -> ETSStruct:
    if pivot_id not in struct.primitives:
        raise KeyError(f"missing pivot primitive: {pivot_id}")
    if new_primitive.id in struct.primitives:
        raise KeyError(f"primitive id already exists: {new_primitive.id}")

    struct.add_primitive(new_primitive)
    if direction == "out":
        struct.add_link(pivot_id, new_primitive.id)
    elif direction == "in":
        struct.add_link(new_primitive.id, pivot_id)
    else:
        raise ValueError("direction must be 'out' or 'in'")

    return struct


def single_level_substruct(struct: ETSStruct, seed_ids: list[str]) -> ETSStruct:
    keep_ids = set(seed_ids)

    for source_id, target_id in struct.links:
        if source_id in seed_ids:
            keep_ids.add(target_id)
        if target_id in seed_ids:
            keep_ids.add(source_id)

    sub = ETSStruct()
    for pid in keep_ids:
        if pid in struct.primitives:
            sub.add_primitive(struct.primitives[pid])

    for source_id, target_id in struct.links:
        if source_id in keep_ids and target_id in keep_ids:
            sub.add_link(source_id, target_id)

    return sub


def reconcile_partial_orders(pairs: list[tuple[str, str]]) -> bool:
    """
    Returns True if acyclic, False if cycle detected.
    """

    nodes = set()
    indegree: dict[str, int] = {}
    adjacency: dict[str, list[str]] = {}

    for source, target in pairs:
        nodes.add(source)
        nodes.add(target)
        adjacency.setdefault(source, []).append(target)
        indegree[target] = indegree.get(target, 0) + 1
        indegree.setdefault(source, 0)

    queue = deque(node for node in nodes if indegree.get(node, 0) == 0)
    visited = 0

    while queue:
        node = queue.popleft()
        visited += 1
        for child in adjacency.get(node, []):
            indegree[child] -= 1
            if indegree[child] == 0:
                queue.append(child)

    return visited == len(nodes)
