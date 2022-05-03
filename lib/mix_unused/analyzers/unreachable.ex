defmodule MixUnused.Analyzers.Unreachable do
  @moduledoc """
  Finds all the reachable functions starting from a set of entrypoints.
  All remaining functions are considered "unused".
  """

  alias MixUnused.Analyzers.Unreachable.Config
  alias MixUnused.Analyzers.Unreachable.Entrypoints
  alias MixUnused.Meta

  @behaviour MixUnused.Analyze

  @impl true
  def message, do: "is unreachable"

  @impl true
  def analyze(data, functions, config) do
    graph =
      Graph.new(type: :directed)
      |> add_calls(data)
      |> add_calls_from_default_functions(functions)

    config = Config.cast(config)
    entrypoints = Entrypoints.entrypoints(config)
    reachables = graph |> Graph.reachable(entrypoints) |> MapSet.new()
    compile_time_calls = calls_evaluated_at_compile_time(data, functions)

    for {mfa, _meta} = call <- functions,
        candidate?(call),
        mfa not in entrypoints,
        mfa not in reachables,
        mfa not in compile_time_calls,
        into: %{},
        do: call
  end

  # Clause to detect an unused struct
  defp candidate?({{_f, :__struct__, _a}, _meta}), do: true
  # Clause to ignore all other generated functions
  defp candidate?({_mfa, %Meta{generated: generated}}), do: not generated

  defp add_calls(graph, data) do
    for {m, calls} <- data,
        {mfa, %{caller: {f, a}}} <- calls,
        reduce: graph do
      acc -> Graph.add_edge(acc, {m, f, a}, mfa)
    end
  end

  defp add_calls_from_default_functions(graph, callables) do
    # A function with default arguments is splitted at compile-time in multiple functions
    #  with different arities.
    #  The main function is indirectly called when a function with default arguments is called,
    #  so the graph should contain an edge for each generated function (from the generated
    #  function to the main one).
    for {{m, f, a} = mfa, %Meta{doc_meta: meta}} <- callables,
        defaults = Map.get(meta, :defaults, 0),
        defaults > 0,
        arity <- (a - defaults)..(a - 1),
        reduce: graph do
      graph -> Graph.add_edge(graph, {m, f, arity}, mfa)
    end
  end

  defp calls_evaluated_at_compile_time(data, functions) do
    for {_m, calls} <- data,
        {mfa, %{caller: nil}} <- calls,
        Map.has_key?(functions, mfa),
        do: mfa
  end
end
