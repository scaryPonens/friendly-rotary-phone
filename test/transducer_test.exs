defmodule MlLab.ETS.TransducerTest do
  use ExUnit.Case, async: true

  alias MlLab.ETS.Examples.BubbleMan
  alias MlLab.ETS.Transducer

  test "bubble man transducer emits a spatial program" do
    assert {:ok,
            [
              :spawn_head,
              :render,
              :grow_torso,
              :render,
              :attach_left_arm,
              :render,
              :attach_right_arm,
              :render
            ], :s4} = BubbleMan.spatial_program()
  end

  test "returns error for invalid transition" do
    t = %Transducer{start_state: :s0, transitions: %{}, emissions: %{}}

    assert {:error, {:invalid_transducer_transition, :s0, :unknown}} =
             Transducer.run(t, [:unknown])
  end
end
