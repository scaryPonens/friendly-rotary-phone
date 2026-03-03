defmodule MlLab.ETS.Examples.BubbleMan do
  @moduledoc """
  Minimal Bubble Man-inspired example for Livebook demos.

  This is intentionally compact: it demonstrates how a class representation and
  struct-generating machine can produce a temporal struct that can later be
  spatially instantiated.
  """

  alias MlLab.ETS.ActiveConstraint
  alias MlLab.ETS.ClassRepresentation
  alias MlLab.ETS.Struct, as: ETSStruct
  alias MlLab.ETS.StructGeneratingMachine
  alias MlLab.ETS.Transducer

  @spec class_representation() :: ClassRepresentation.t()
  def class_representation do
    ClassRepresentation.new([
      %ActiveConstraint{
        id: :seed_head,
        required_labels: [:head],
        required_links: []
      },
      %ActiveConstraint{
        id: :grow_torso,
        required_labels: [:head, :torso],
        required_links: [head: :torso]
      },
      %ActiveConstraint{
        id: :attach_limbs,
        required_labels: [:torso, :left_arm, :right_arm],
        required_links: [torso: :left_arm, torso: :right_arm]
      }
    ])
  end

  @spec machine() :: StructGeneratingMachine.t()
  def machine do
    %StructGeneratingMachine{
      start_state: :q0,
      accept_states: MapSet.new([:q3]),
      transitions: %{
        {:q0, :step} => :q1,
        {:q1, :step} => :q2,
        {:q2, :step} => :q3
      },
      emissions: %{
        {:q0, :step} => :seed_head,
        {:q1, :step} => :grow_torso,
        {:q2, :step} => :attach_limbs
      }
    }
  end

  @spec generate() :: {:ok, ETSStruct.t(), atom(), [atom()]} | {:error, term()}
  def generate do
    StructGeneratingMachine.generate(ETSStruct.new(), class_representation(), machine(), [
      :step,
      :step,
      :step
    ])
  end

  @doc """
  Converts generated primitive labels into symbolic spatial instructions.
  """
  @spec spatial_program() :: {:ok, [atom()], atom()} | {:error, term()}
  def spatial_program do
    with {:ok, struct, _state, _trace} <- generate() do
      desired_order = [:head, :torso, :left_arm, :right_arm]

      labels =
        struct.primitives
        |> Map.values()
        |> Enum.map(& &1.label)
        |> Enum.sort_by(fn label -> Enum.find_index(desired_order, &(&1 == label)) || 999 end)

      Transducer.run(transducer(), labels)
    end
  end

  @spec transducer() :: Transducer.t()
  def transducer do
    %Transducer{
      start_state: :s0,
      transitions: %{
        {:s0, :head} => :s1,
        {:s1, :torso} => :s2,
        {:s2, :left_arm} => :s3,
        {:s3, :right_arm} => :s4
      },
      emissions: %{
        {:s0, :head} => [:spawn_head, :render],
        {:s1, :torso} => [:grow_torso, :render],
        {:s2, :left_arm} => [:attach_left_arm, :render],
        {:s3, :right_arm} => [:attach_right_arm, :render]
      }
    }
  end
end
