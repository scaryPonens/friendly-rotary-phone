defmodule MlLab.ETS.DebugTrace do
  @moduledoc """
  Constraint-level tracing utilities for ETS generation.

  Produces step-by-step snapshots useful for Livebook debugging.
  """

  alias MlLab.ETS.ClassRepresentation
  alias MlLab.ETS.Struct, as: ETSStruct
  alias MlLab.ETS.StructGeneratingMachine

  @type trace_row :: %{
          step: non_neg_integer(),
          event: atom(),
          from_state: atom(),
          to_state: atom() | nil,
          emission: atom() | nil,
          primitive_count: non_neg_integer(),
          link_count: non_neg_integer(),
          status: :ok | :error,
          reason: term() | nil
        }

  @spec run(ETSStruct.t(), ClassRepresentation.t(), StructGeneratingMachine.t(), [atom()]) ::
          {:ok, ETSStruct.t(), atom(), [trace_row()]} | {:error, [trace_row()]}
  def run(
        %ETSStruct{} = struct,
        %ClassRepresentation{} = class_rep,
        %StructGeneratingMachine{} = machine,
        events
      ) do
    Enum.reduce_while(
      Enum.with_index(events, 1),
      {:ok, struct, machine.start_state, []},
      fn {event, step}, {:ok, acc_struct, state, rows} ->
        case step_once(acc_struct, class_rep, machine, state, event, step) do
          {:ok, next_struct, next_state, row} ->
            {:cont, {:ok, next_struct, next_state, [row | rows]}}

          {:error, row} ->
            {:halt, {:error, Enum.reverse([row | rows])}}
        end
      end
    )
    |> case do
      {:ok, final_struct, final_state, rows} ->
        {:ok, final_struct, final_state, Enum.reverse(rows)}

      {:error, rows} ->
        {:error, rows}
    end
  end

  defp step_once(struct, class_rep, machine, state, event, step) do
    with {:ok, to_state} <- fetch_transition(machine, state, event),
         {:ok, next_struct, emission} <- apply_emission(struct, class_rep, machine, state, event) do
      row = %{
        step: step,
        event: event,
        from_state: state,
        to_state: to_state,
        emission: emission,
        primitive_count: map_size(next_struct.primitives),
        link_count: MapSet.size(next_struct.links),
        status: :ok,
        reason: nil
      }

      {:ok, next_struct, to_state, row}
    else
      {:error, reason} ->
        row = %{
          step: step,
          event: event,
          from_state: state,
          to_state: nil,
          emission: nil,
          primitive_count: map_size(struct.primitives),
          link_count: MapSet.size(struct.links),
          status: :error,
          reason: reason
        }

        {:error, row}
    end
  end

  defp fetch_transition(%StructGeneratingMachine{transitions: transitions}, state, event) do
    case Map.fetch(transitions, {state, event}) do
      {:ok, next_state} -> {:ok, next_state}
      :error -> {:error, {:invalid_transition, state, event}}
    end
  end

  defp apply_emission(
         struct,
         class_rep,
         %StructGeneratingMachine{emissions: emissions},
         state,
         event
       ) do
    case Map.fetch(emissions, {state, event}) do
      :error ->
        {:ok, struct, nil}

      {:ok, constraint_id} ->
        case ClassRepresentation.fetch_constraint(class_rep, constraint_id) do
          {:ok, constraint} ->
            next = MlLab.ETS.ActiveConstraint.ext(struct, constraint)
            {:ok, next, constraint_id}

          :error ->
            {:error, {:missing_constraint, constraint_id}}
        end
    end
  end
end
