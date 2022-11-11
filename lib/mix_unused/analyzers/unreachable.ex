defmodule MixUnused.Analyzers.Unreachable do
  @moduledoc """
  Reports all the exported functions that are not reachable from a set of well-known used functions.
  """

  alias MixUnused.Analyzers.Calls
  alias MixUnused.Analyzers.Unreachable.Config
  alias MixUnused.Analyzers.Unreachable.Usages
  alias MixUnused.Meta

  @behaviour MixUnused.Analyze

  @impl true
  def message, do: "is unreachable"

  @impl true
  def analyze(data, exports, config) do
    config = Config.cast(config)
    graph = Calls.calls_graph(data, exports)

    usages =
      Usages.usages(config, %Usages.Context{calls: graph, exports: exports})

    reachables = graph |> Graph.reachable(usages) |> MapSet.new()
    called_at_compile_time = Calls.called_at_compile_time(data, exports)

    for {mfa, _meta} = call <- exports,
        filter_transitive_call?(config, graph, mfa),
        filter_generated_function?(call),
        mfa not in usages,
        mfa not in reachables,
        mfa not in called_at_compile_time,
        into: %{},
        do: call
  end

  @spec filter_transitive_call?(Config.t(), Graph.t(), mfa()) :: boolean()
  defp filter_transitive_call?(
         %Config{report_transitively_unused: report_transitively_unused},
         graph,
         mfa
       ) do
    report_transitively_unused or Graph.in_degree(graph, mfa) == 0
  end

  # Clause to detect an unused struct (it is generated)
  defp filter_generated_function?({{_f, :__struct__, _a}, _meta}), do: true
  # Clause to ignore all generated functions
  defp filter_generated_function?({_mfa, %Meta{generated: true}}), do: false
  defp filter_generated_function?(_), do: true
end
