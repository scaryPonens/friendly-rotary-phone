defmodule MlLab.ETS.Primitive do
  @moduledoc """
  Basic ETS primitive.

  A primitive is the smallest event-like unit used to build an ETS struct.
  """

  @enforce_keys [:id, :label]
  defstruct [:id, :label, :kind, :metadata]

  @type t :: %__MODULE__{
          id: term(),
          label: atom() | String.t(),
          kind: atom() | nil,
          metadata: map() | nil
        }

  @spec new(term(), atom() | String.t(), keyword()) :: t()
  def new(id, label, opts \\ []) do
    %__MODULE__{
      id: id,
      label: label,
      kind: Keyword.get(opts, :kind),
      metadata: Keyword.get(opts, :metadata, %{})
    }
  end
end
