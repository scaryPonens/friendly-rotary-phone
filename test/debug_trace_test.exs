defmodule MlLab.ETS.DebugTraceTest do
  use ExUnit.Case, async: true

  alias MlLab.ETS.DebugTrace
  alias MlLab.ETS.Examples.BubbleMan
  alias MlLab.ETS.Struct, as: ETSStruct

  test "returns step rows for successful generation" do
    assert {:ok, _struct, :q3, rows} =
             DebugTrace.run(
               ETSStruct.new(),
               BubbleMan.class_representation(),
               BubbleMan.machine(),
               [:step, :step, :step]
             )

    assert length(rows) == 3
    assert Enum.all?(rows, &(&1.status == :ok))
    assert List.last(rows).primitive_count >= 4
  end

  test "returns rows with error status when transition fails" do
    assert {:error, rows} =
             DebugTrace.run(
               ETSStruct.new(),
               BubbleMan.class_representation(),
               BubbleMan.machine(),
               [:step, :invalid_event]
             )

    assert length(rows) == 2
    assert List.last(rows).status == :error
    assert List.last(rows).reason == {:invalid_transition, :q1, :invalid_event}
  end
end
