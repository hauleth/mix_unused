defmodule MixUnused.Analyzers.Unreachable do
  @moduledoc """
  Finds all the reachable exported functions starting from a set of well-known used functions.
  All remaining functions are considered "unused".
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
    usages = Usages.usages(config, exports)
    reachables = graph |> Graph.reachable(usages) |> MapSet.new()
    called_at_compile_time = Calls.called_at_compile_time(data, exports)

    for {mfa, _meta} = call <- exports,
        candidate?(call),
        mfa not in usages,
        mfa not in reachables,
        mfa not in called_at_compile_time,
        into: %{},
        do: call
  end

  # Clause to detect an unused struct (it is generated)
  defp candidate?({{_f, :__struct__, _a}, _meta}), do: true
  # Clause to ignore all generated functions
  defp candidate?({_mfa, %Meta{generated: true}}), do: false
  defp candidate?(_), do: true
end
