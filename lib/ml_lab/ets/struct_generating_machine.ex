defmodule MlLab.ETS.StructGeneratingMachine do
  @moduledoc """
  A small finite-state machine for class element generation.

  `transitions` map `{state, event}` to `next_state`.
  `emissions` map `{state, event}` to constraint IDs that should be applied.
  """

  alias MlLab.ETS.ActiveConstraint
  alias MlLab.ETS.ClassRepresentation
  alias MlLab.ETS.Struct, as: ETSStruct

  @enforce_keys [:start_state, :accept_states, :transitions, :emissions]
  defstruct start_state: nil,
            accept_states: MapSet.new(),
            transitions: %{},
            emissions: %{}

  @type state :: atom()
  @type event :: atom()

  @type t :: %__MODULE__{
          start_state: state(),
          accept_states: MapSet.t(state()),
          transitions: %{{state(), event()} => state()},
          emissions: %{{state(), event()} => atom()}
        }

  @spec generate(ETSStruct.t(), ClassRepresentation.t(), t(), [event()]) ::
          {:ok, ETSStruct.t(), state(), [atom()]} | {:error, term()}
  def generate(%ETSStruct{} = struct, %ClassRepresentation{} = class_rep, %__MODULE__{} = machine, events) do
    Enum.reduce_while(events, {:ok, struct, machine.start_state, []}, fn event,
                                                                         {:ok, acc_struct, state, trace} ->
      with {:ok, next_state} <- fetch_transition(machine, state, event),
           {:ok, next_struct, maybe_constraint_id} <-
             apply_emission(acc_struct, class_rep, machine, state, event) do
        next_trace = if maybe_constraint_id, do: [maybe_constraint_id | trace], else: trace
        {:cont, {:ok, next_struct, next_state, next_trace}}
      else
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, final_struct, final_state, trace} ->
        if MapSet.member?(machine.accept_states, final_state) do
          {:ok, final_struct, final_state, Enum.reverse(trace)}
        else
          {:error, {:non_accepting_final_state, final_state}}
        end

      other ->
        other
    end
  end

  defp fetch_transition(%__MODULE__{transitions: transitions}, state, event) do
    case Map.fetch(transitions, {state, event}) do
      {:ok, next_state} -> {:ok, next_state}
      :error -> {:error, {:invalid_transition, state, event}}
    end
  end

  defp apply_emission(struct, class_rep, %__MODULE__{emissions: emissions}, state, event) do
    case Map.fetch(emissions, {state, event}) do
      :error ->
        {:ok, struct, nil}

      {:ok, constraint_id} ->
        with {:ok, %ActiveConstraint{} = constraint} <-
               ClassRepresentation.fetch_constraint(class_rep, constraint_id) do
          {:ok, ActiveConstraint.ext(struct, constraint), constraint_id}
        else
          :error -> {:error, {:missing_constraint, constraint_id}}
        end
    end
  end
end
