defmodule MlLab.ETS.StructGeneratingMachineTest do
  use ExUnit.Case, async: true

  alias MlLab.ETS.Examples.BubbleMan
  alias MlLab.ETS.Struct, as: ETSStruct
  alias MlLab.ETS.StructGeneratingMachine

  test "returns error for invalid transition" do
    assert {:error, {:invalid_transition, :q0, :invalid_event}} =
             StructGeneratingMachine.generate(
               ETSStruct.new(),
               BubbleMan.class_representation(),
               BubbleMan.machine(),
               [:invalid_event]
             )
  end
end
