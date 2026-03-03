defmodule MlLab.ETS.Struct do
  @moduledoc """
  Temporal ETS struct represented as a graph of primitives and directed links.

  This module provides core operations inspired by the thesis primitives:
  adding primitives, linking them, extracting substructs, and assembly.
  """

  alias MlLab.ETS.Primitive

  @enforce_keys [:primitives, :links]
  defstruct primitives: %{}, links: MapSet.new()

  @type primitive_id :: term()
  @type link :: {primitive_id(), primitive_id()}

  @type t :: %__MODULE__{
          primitives: %{optional(primitive_id()) => Primitive.t()},
          links: MapSet.t(link())
        }

  @spec new() :: t()
  def new, do: %__MODULE__{}

  @spec add_primitive(t(), Primitive.t()) :: t()
  def add_primitive(%__MODULE__{} = struct, %Primitive{id: id} = primitive) do
    %{struct | primitives: Map.put(struct.primitives, id, primitive)}
  end

  @spec add_link(t(), primitive_id(), primitive_id()) :: {:ok, t()} | {:error, atom()}
  def add_link(%__MODULE__{} = struct, from_id, to_id) do
    cond do
      not Map.has_key?(struct.primitives, from_id) ->
        {:error, :missing_from_primitive}

      not Map.has_key?(struct.primitives, to_id) ->
        {:error, :missing_to_primitive}

      true ->
        {:ok, %{struct | links: MapSet.put(struct.links, {from_id, to_id})}}
    end
  end

  @spec primitive_ids_with_label(t(), atom() | String.t()) :: [primitive_id()]
  def primitive_ids_with_label(%__MODULE__{} = struct, label) do
    struct.primitives
    |> Enum.filter(fn {_id, primitive} -> primitive.label == label end)
    |> Enum.map(&elem(&1, 0))
  end

  @doc """
  Returns a struct that includes only the given primitive IDs and links between them.
  """
  @spec substruct(t(), [primitive_id()]) :: t()
  def substruct(%__MODULE__{} = struct, ids) do
    id_set = MapSet.new(ids)

    primitives =
      struct.primitives
      |> Enum.filter(fn {id, _} -> MapSet.member?(id_set, id) end)
      |> Map.new()

    links =
      struct.links
      |> Enum.filter(fn {from_id, to_id} ->
        MapSet.member?(id_set, from_id) and MapSet.member?(id_set, to_id)
      end)
      |> MapSet.new()

    %__MODULE__{primitives: primitives, links: links}
  end

  @doc """
  Assembly operation: merges two structs when primitive IDs don't collide.
  """
  @spec assemble(t(), t()) :: {:ok, t()} | {:error, {:id_collision, [primitive_id()]}}
  def assemble(%__MODULE__{} = left, %__MODULE__{} = right) do
    collisions = Map.keys(left.primitives) |> Enum.filter(&Map.has_key?(right.primitives, &1))

    case collisions do
      [] ->
        {:ok,
         %__MODULE__{
           primitives: Map.merge(left.primitives, right.primitives),
           links: MapSet.union(left.links, right.links)
         }}

      ids ->
        {:error, {:id_collision, ids}}
    end
  end

  @spec to_edge_list(t()) :: [link()]
  def to_edge_list(%__MODULE__{} = struct) do
    struct.links |> Enum.sort()
  end
end
