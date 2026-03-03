defmodule MlLab.ETS.ClassRepresentation do
  @moduledoc """
  Class representation using a collection of named active constraints.
  """

  alias MlLab.ETS.ActiveConstraint

  @enforce_keys [:constraints]
  defstruct constraints: %{}

  @type t :: %__MODULE__{constraints: %{optional(atom()) => ActiveConstraint.t()}}

  @spec new([ActiveConstraint.t()]) :: t()
  def new(constraints) do
    constraint_map = Map.new(constraints, fn constraint -> {constraint.id, constraint} end)
    %__MODULE__{constraints: constraint_map}
  end

  @spec fetch_constraint(t(), atom()) :: {:ok, ActiveConstraint.t()} | :error
  def fetch_constraint(%__MODULE__{} = class_representation, id) do
    Map.fetch(class_representation.constraints, id)
  end
end
