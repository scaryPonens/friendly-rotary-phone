defmodule MlLab.ETS.MachineGraphvizTest do
  use ExUnit.Case, async: true

  alias MlLab.ETS.Examples.BubbleMan
  alias MlLab.ETS.MachineGraphviz

  test "exports machine as dot" do
    dot = MachineGraphviz.to_dot(BubbleMan.machine(), graph_name: "bubble_man")

    assert String.contains?(dot, "digraph bubble_man")
    assert String.contains?(dot, ~s(start -> "q0"))
    assert String.contains?(dot, ~s("q0" -> "q1" [label="step / seed_head"]))
    assert String.contains?(dot, ~s("q3" [shape=doublecircle]))
  end
end
