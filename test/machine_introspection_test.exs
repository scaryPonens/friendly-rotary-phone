defmodule MlLab.ETS.MachineIntrospectionTest do
  use ExUnit.Case, async: true

  alias MlLab.ETS.Examples.BubbleMan
  alias MlLab.ETS.MachineIntrospection

  test "exposes transition and emission rows" do
    machine = BubbleMan.machine()

    transitions = MachineIntrospection.transition_rows(machine)
    emissions = MachineIntrospection.emission_rows(machine)

    assert %{from: "q0", event: "step", to: "q1"} in transitions
    assert %{state: "q1", event: "step", emission: "grow_torso"} in emissions
  end
end
