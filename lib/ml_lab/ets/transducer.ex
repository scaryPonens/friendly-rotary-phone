defmodule MlLab.ETS.Transducer do
  @moduledoc """
  Minimal deterministic transducer for thesis-inspired spatial instantiation.

  Given a sequence of primitive labels, emits symbolic rendering instructions.
  """

  @type state :: atom()
  @type label :: atom() | String.t()
  @type instruction :: atom()

  @type t :: %__MODULE__{
          start_state: state(),
          transitions: %{{state(), label()} => state()},
          emissions: %{{state(), label()} => [instruction()]}
        }

  @enforce_keys [:start_state, :transitions, :emissions]
  defstruct start_state: nil, transitions: %{}, emissions: %{}

  @spec run(t(), [label()]) :: {:ok, [instruction()], state()} | {:error, term()}
  def run(%__MODULE__{} = transducer, labels) do
    Enum.reduce_while(labels, {:ok, [], transducer.start_state}, fn label,
                                                                    {:ok, acc_instructions, state} ->
      with {:ok, next_state} <- fetch_transition(transducer, state, label) do
        emitted = Map.get(transducer.emissions, {state, label}, [])
        {:cont, {:ok, acc_instructions ++ emitted, next_state}}
      else
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp fetch_transition(%__MODULE__{transitions: transitions}, state, label) do
    case Map.fetch(transitions, {state, label}) do
      {:ok, next_state} -> {:ok, next_state}
      :error -> {:error, {:invalid_transducer_transition, state, label}}
    end
  end
end
