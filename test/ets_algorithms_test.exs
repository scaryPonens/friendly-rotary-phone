defmodule MlLab.ETS.AlgorithmsTest do
  use ExUnit.Case, async: true

  alias MlLab.ETS.Algorithms
  alias MlLab.ETS.Primitive
  alias MlLab.ETS.Struct, as: ETSStruct

  test "primitive_attachment adds primitive and link" do
    base = ETSStruct.new() |> ETSStruct.add_primitive(Primitive.new(:head, :head))

    assert {:ok, updated} =
             Algorithms.primitive_attachment(base, :head, Primitive.new(:torso, :torso), :out)

    assert Map.has_key?(updated.primitives, :torso)
    assert MapSet.member?(updated.links, {:head, :torso})
  end

  test "single_level_substruct includes one-hop neighbors" do
    struct =
      ETSStruct.new()
      |> ETSStruct.add_primitive(Primitive.new(:a, :head))
      |> ETSStruct.add_primitive(Primitive.new(:b, :torso))
      |> ETSStruct.add_primitive(Primitive.new(:c, :left_arm))
      |> then(fn s ->
        {:ok, s} = ETSStruct.add_link(s, :a, :b)
        s
      end)
      |> then(fn s ->
        {:ok, s} = ETSStruct.add_link(s, :b, :c)
        s
      end)

    sub = Algorithms.single_level_substruct(struct, [:a])

    assert Map.keys(sub.primitives) |> Enum.sort() == [:a, :b]
    assert MapSet.member?(sub.links, {:a, :b})
    refute MapSet.member?(sub.links, {:b, :c})
  end

  test "reconcile_partial_orders catches cycles" do
    assert :ok = Algorithms.reconcile_partial_orders([{:a, :b}, {:b, :c}])
    assert {:error, :cycle_detected} = Algorithms.reconcile_partial_orders([{:a, :b}, {:b, :a}])
  end
end
