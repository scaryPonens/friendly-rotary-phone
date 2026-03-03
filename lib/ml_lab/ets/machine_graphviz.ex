defmodule MlLab.ETS.MachineGraphviz do
  @moduledoc """
  Graphviz DOT export helpers for ETS struct-generating machines.
  """

  alias MlLab.ETS.StructGeneratingMachine

  @spec to_dot(StructGeneratingMachine.t(), keyword()) :: String.t()
  def to_dot(%StructGeneratingMachine{} = machine, opts \\ []) do
    graph_name = Keyword.get(opts, :graph_name, "ets_machine")

    transition_lines =
      machine.transitions
      |> Enum.map(fn {{from, event}, to} ->
        emission = Map.get(machine.emissions, {from, event})
        label = build_edge_label(event, emission)

        "  #{q(from)} -> #{q(to)} [label=#{q(label)}];"
      end)
      |> Enum.sort()

    accept_lines =
      machine.accept_states
      |> Enum.map(fn state -> "  #{q(state)} [shape=doublecircle];" end)
      |> Enum.sort()

    ([
       "digraph #{graph_name} {",
       "  rankdir=LR;",
       "  node [shape=circle];",
       "  start [shape=point];",
       "  start -> #{q(machine.start_state)};"
     ] ++
       accept_lines ++
       transition_lines ++
       ["}"])
    |> Enum.join("\n")
  end

  @spec write_dot!(StructGeneratingMachine.t(), Path.t(), keyword()) :: Path.t()
  def write_dot!(%StructGeneratingMachine{} = machine, path, opts \\ []) do
    dot = to_dot(machine, opts)
    File.write!(path, dot)
    path
  end

  defp build_edge_label(event, nil), do: to_string(event)
  defp build_edge_label(event, emission), do: "#{event} / #{emission}"

  defp q(value), do: ~s("#{value}")
end
