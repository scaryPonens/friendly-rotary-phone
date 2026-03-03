defmodule MlLab.ETS.StructTest do
  use ExUnit.Case, async: true

  alias MlLab.ETS.Primitive
  alias MlLab.ETS.Struct, as: ETSStruct

  test "assemble merges non-overlapping structs" do
    left =
      ETSStruct.new()
      |> ETSStruct.add_primitive(Primitive.new(:a, :head))

    right =
      ETSStruct.new()
      |> ETSStruct.add_primitive(Primitive.new(:b, :torso))

    assert {:ok, merged} = ETSStruct.assemble(left, right)
    assert Map.keys(merged.primitives) |> Enum.sort() == [:a, :b]
  end

  test "substruct keeps only selected ids and their links" do
    with {:ok, struct1} <-
           ETSStruct.new()
           |> ETSStruct.add_primitive(Primitive.new(:a, :head))
           |> ETSStruct.add_primitive(Primitive.new(:b, :torso))
           |> ETSStruct.add_primitive(Primitive.new(:c, :left_arm))
           |> then(&ETSStruct.add_link(&1, :a, :b)),
         {:ok, struct2} <- ETSStruct.add_link(struct1, :b, :c) do
      sub = ETSStruct.substruct(struct2, [:a, :b])
      assert Map.keys(sub.primitives) |> Enum.sort() == [:a, :b]
      assert MapSet.member?(sub.links, {:a, :b})
      refute MapSet.member?(sub.links, {:b, :c})
    end
  end
end
