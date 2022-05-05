defmodule MixUnused.Analyzers.Unreachable do
  @moduledoc """
  Finds all the reachable functions starting from a set of entrypoints.
  All remaining functions are considered "unused".
  """

  alias MixUnused.Analyzers.Calls
  alias MixUnused.Analyzers.Unreachable.Config
  alias MixUnused.Analyzers.Unreachable.Entrypoints
  alias MixUnused.Meta

  @behaviour MixUnused.Analyze

  @impl true
  def message, do: "is unreachable"

  @impl true
  def analyze(data, functions, config) do
    config = Config.cast(config)
    graph = Calls.calls_graph(data, functions)
    entrypoints = Entrypoints.entrypoints(config, functions)
    reachables = graph |> Graph.reachable(entrypoints) |> MapSet.new()
    called_at_compile_time = Calls.called_at_compile_time(data, functions)

    for {mfa, _meta} = call <- functions,
        candidate?(call),
        mfa not in entrypoints,
        mfa not in reachables,
        mfa not in called_at_compile_time,
        into: %{},
        do: call
  end

  # Clause to detect an unused struct
  defp candidate?({{_f, :__struct__, _a}, _meta}), do: true
  # Clause to ignore all generated functions except callbacks
  defp candidate?({_mfa, %Meta{generated: true, callback: false}}), do: false
  defp candidate?(_), do: true
end
