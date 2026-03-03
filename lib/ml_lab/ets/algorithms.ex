defmodule MlLab.ETS.Algorithms do
  @moduledoc """
  Thesis-inspired ETS algorithms (practical subset).

  These functions provide a faithful *shape* of the appendix operations while
  remaining idiomatic and testable in Elixir.
  """

  alias MlLab.ETS.Primitive
  alias MlLab.ETS.Struct, as: ETSStruct

  @type primitive_id :: ETSStruct.primitive_id()

  @doc """
  Struct Link algorithm: links two existing primitives.
  """
  @spec struct_link(ETSStruct.t(), primitive_id(), primitive_id()) ::
          {:ok, ETSStruct.t()} | {:error, atom()}
  def struct_link(%ETSStruct{} = struct, from_id, to_id) do
    ETSStruct.add_link(struct, from_id, to_id)
  end

  @doc """
  Primitive attachment algorithm.

  Attaches `new_primitive` to `pivot_id` either as outgoing (`:out`) or incoming (`:in`).
  """
  @spec primitive_attachment(ETSStruct.t(), primitive_id(), Primitive.t(), :out | :in) ::
          {:ok, ETSStruct.t()} | {:error, atom()}
  def primitive_attachment(
        %ETSStruct{} = struct,
        pivot_id,
        %Primitive{} = new_primitive,
        direction
      )
      when direction in [:out, :in] do
    cond do
      not Map.has_key?(struct.primitives, pivot_id) ->
        {:error, :missing_pivot_primitive}

      Map.has_key?(struct.primitives, new_primitive.id) ->
        {:error, :id_already_exists}

      true ->
        next = ETSStruct.add_primitive(struct, new_primitive)

        case direction do
          :out -> ETSStruct.add_link(next, pivot_id, new_primitive.id)
          :in -> ETSStruct.add_link(next, new_primitive.id, pivot_id)
        end
    end
  end

  @doc """
  Single-level substruct algorithm.

  Given seed IDs, keeps those IDs and their one-hop neighbors.
  """
  @spec single_level_substruct(ETSStruct.t(), [primitive_id()]) :: ETSStruct.t()
  def single_level_substruct(%ETSStruct{} = struct, seed_ids) do
    seed_set = MapSet.new(seed_ids)

    one_hop =
      struct.links
      |> Enum.reduce(seed_set, fn {from_id, to_id}, acc ->
        cond do
          MapSet.member?(seed_set, from_id) -> MapSet.put(acc, to_id)
          MapSet.member?(seed_set, to_id) -> MapSet.put(acc, from_id)
          true -> acc
        end
      end)

    ETSStruct.substruct(struct, MapSet.to_list(one_hop))
  end

  @doc """
  Single-level assembly with a basic superimposition rule.

  If IDs collide with the same label, keep left primitive and merge metadata.
  If IDs collide with different labels, return an error.
  """
  @spec single_level_assembly(ETSStruct.t(), ETSStruct.t()) ::
          {:ok, ETSStruct.t()} | {:error, {:label_mismatch, primitive_id()}}
  def single_level_assembly(%ETSStruct{} = left, %ETSStruct{} = right) do
    {merged_primitives, error} =
      Enum.reduce(right.primitives, {left.primitives, nil}, fn {id, right_primitive},
                                                               {acc, err} ->
        if err do
          {acc, err}
        else
          case Map.fetch(acc, id) do
            :error ->
              {Map.put(acc, id, right_primitive), nil}

            {:ok, left_primitive} ->
              if left_primitive.label == right_primitive.label do
                merged = %Primitive{
                  left_primitive
                  | metadata:
                      Map.merge(left_primitive.metadata || %{}, right_primitive.metadata || %{})
                }

                {Map.put(acc, id, merged), nil}
              else
                {acc, {:label_mismatch, id}}
              end
          end
        end
      end)

    if error do
      {:error, error}
    else
      {:ok,
       %ETSStruct{
         primitives: merged_primitives,
         links: MapSet.union(left.links, right.links)
       }}
    end
  end

  @doc """
  Reconciling partial order constraints.

  Verifies that directed precedence pairs do not introduce a cycle.
  Returns `:ok` or `{:error, :cycle_detected}`.
  """
  @spec reconcile_partial_orders([{primitive_id(), primitive_id()}]) ::
          :ok | {:error, :cycle_detected}
  def reconcile_partial_orders(pairs) do
    nodes = pairs |> Enum.flat_map(fn {a, b} -> [a, b] end) |> MapSet.new() |> MapSet.to_list()

    indegree =
      Enum.reduce(pairs, Map.new(nodes, &{&1, 0}), fn {_from, to}, acc ->
        Map.update!(acc, to, &(&1 + 1))
      end)

    adjacency =
      Enum.reduce(pairs, %{}, fn {from, to}, acc ->
        Map.update(acc, from, [to], &[to | &1])
      end)

    queue = indegree |> Enum.filter(fn {_n, d} -> d == 0 end) |> Enum.map(&elem(&1, 0))

    visited_count = kahn(queue, indegree, adjacency, 0)

    if visited_count == length(nodes), do: :ok, else: {:error, :cycle_detected}
  end

  defp kahn([], _indegree, _adjacency, visited), do: visited

  defp kahn([node | rest], indegree, adjacency, visited) do
    {next_indegree, next_zeroes} =
      adjacency
      |> Map.get(node, [])
      |> Enum.reduce({indegree, []}, fn child, {acc_indegree, acc_zeroes} ->
        updated = Map.update!(acc_indegree, child, &(&1 - 1))

        if Map.fetch!(updated, child) == 0 do
          {updated, [child | acc_zeroes]}
        else
          {updated, acc_zeroes}
        end
      end)

    kahn(rest ++ next_zeroes, next_indegree, adjacency, visited + 1)
  end
end
