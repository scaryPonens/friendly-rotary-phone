defmodule MlLab.ETS.MachineIntrospection do
  @moduledoc """
  Helpers for visualizing struct-generating machines in Livebook.
  """

  alias MlLab.ETS.StructGeneratingMachine

  @spec transition_rows(StructGeneratingMachine.t()) :: [map()]
  def transition_rows(%StructGeneratingMachine{} = machine) do
    machine.transitions
    |> Enum.map(fn {{from, event}, to} ->
      %{from: to_string(from), event: to_string(event), to: to_string(to)}
    end)
    |> Enum.sort_by(&{&1.from, &1.event, &1.to})
  end

  @spec emission_rows(StructGeneratingMachine.t()) :: [map()]
  def emission_rows(%StructGeneratingMachine{} = machine) do
    machine.emissions
    |> Enum.map(fn {{state, event}, constraint_id} ->
      %{state: to_string(state), event: to_string(event), emission: to_string(constraint_id)}
    end)
    |> Enum.sort_by(&{&1.state, &1.event, &1.emission})
  end
end
