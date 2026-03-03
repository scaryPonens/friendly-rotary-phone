from friendly_rotary_phone.ets import ActiveConstraint, ETSStruct, apply_constraint


def test_apply_constraint_adds_primitives_and_links():
    struct = ETSStruct()
    constraint = ActiveConstraint(
        required_labels=["head", "torso"],
        required_links=[("head", "torso")],
    )

    apply_constraint(struct, constraint)

    labels = {p.label for p in struct.primitives.values()}
    assert labels == {"head", "torso"}
    assert len(struct.links) == 1
