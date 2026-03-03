defmodule MlLabTest do
  use ExUnit.Case
  doctest MlLab

  test "runs bubble man generation" do
    assert {:ok, struct, :q3, [:seed_head, :grow_torso, :attach_limbs]} = MlLab.generate_bubble_man()

    labels = struct.primitives |> Map.values() |> Enum.map(& &1.label)

    assert :head in labels
    assert :torso in labels
    assert :left_arm in labels
    assert :right_arm in labels
    assert MapSet.size(struct.links) == 3
  end
end
