defmodule MlLab do
  @moduledoc """
  Entry points for ML Lab and ETS experiments.
  """

  alias MlLab.ETS.Examples.BubbleMan

  @doc """
  Runs the minimal Bubble Man ETS generator.

  ## Examples

      iex> {:ok, _struct, :q3, trace} = MlLab.generate_bubble_man()
      iex> trace
      [:seed_head, :grow_torso, :attach_limbs]

  """
  def generate_bubble_man do
    BubbleMan.generate()
  end
end
