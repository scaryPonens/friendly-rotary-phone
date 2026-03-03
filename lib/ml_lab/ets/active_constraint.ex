defmodule MlLab.ETS.ActiveConstraint do
  @moduledoc """
  Simplified active structural constraint.

  `ext/2` attempts to extend a working ETS struct by ensuring required labels exist,
  then applies required links by label.
  """

  alias MlLab.ETS.Primitive
  alias MlLab.ETS.Struct, as: ETSStruct

  @enforce_keys [:id, :required_labels, :required_links]
  defstruct id: nil,
            required_labels: [],
            required_links: [],
            anchor_labels: [],
            open_labels: []

  @type label :: atom() | String.t()

  @type t :: %__MODULE__{
          id: atom(),
          required_labels: [label()],
          required_links: [{label(), label()}],
          anchor_labels: [label()],
          open_labels: [label()]
        }

  @spec ext(ETSStruct.t(), t()) :: ETSStruct.t()
  def ext(%ETSStruct{} = struct, %__MODULE__{} = constraint) do
    {struct, label_to_id} = ensure_required_labels(struct, constraint.required_labels)

    Enum.reduce(constraint.required_links, struct, fn {from_label, to_label}, acc ->
      from_id = Map.fetch!(label_to_id, from_label)
      to_id = Map.fetch!(label_to_id, to_label)

      case ETSStruct.add_link(acc, from_id, to_id) do
        {:ok, next} -> next
        {:error, _reason} -> acc
      end
    end)
  end

  defp ensure_required_labels(struct, labels) do
    Enum.reduce(labels, {struct, %{}}, fn label, {acc_struct, acc_map} ->
      case ETSStruct.primitive_ids_with_label(acc_struct, label) do
        [existing_id | _] ->
          {acc_struct, Map.put(acc_map, label, existing_id)}

        [] ->
          id = {label, System.unique_integer([:positive])}
          primitive = Primitive.new(id, label)
          next_struct = ETSStruct.add_primitive(acc_struct, primitive)
          {next_struct, Map.put(acc_map, label, id)}
      end
    end)
  end
end
