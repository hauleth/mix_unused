defmodule MixUnused.Analyzers.Calls do
  @moduledoc false

  alias MixUnused.Exports
  alias MixUnused.Meta
  alias MixUnused.Tracer

  @doc """
  Creates a graph where each node is a function and an edge from `f` to `g`
  means that the function `f` calls `g`.
  """
  @spec calls_graph(Tracer.data(), Exports.t()) :: Graph.t()
  def calls_graph(data, functions) do
    Graph.new(type: :directed)
    |> add_calls(data)
    |> add_calls_from_default_functions(functions)
  end

  defp add_calls(graph, data) do
    for {m, calls} <- data,
        {mfa, %{caller: {f, a}}} <- calls,
        reduce: graph do
      acc -> Graph.add_edge(acc, {m, f, a}, mfa)
    end
  end

  defp add_calls_from_default_functions(graph, functions) do
    # A function with default arguments is splitted at compile-time in multiple functions
    #  with different arities.
    #  The main function is indirectly called when a function with default arguments is called,
    #  so the graph should contain an edge for each generated function (from the generated
    #  function to the main one).
    for {{m, f, a} = mfa, %Meta{doc_meta: meta}} <- functions,
        defaults = Map.get(meta, :defaults, 0),
        defaults > 0,
        arity <- (a - defaults)..(a - 1),
        reduce: graph do
      graph -> Graph.add_edge(graph, {m, f, arity}, mfa)
    end
  end

  @doc """
  Gets all the functions called from some module at compile-time.
  """
  @spec called_at_compile_time(Tracer.data(), Exports.t()) :: [mfa()]
  def called_at_compile_time(data, functions) do
    for {_m, calls} <- data,
        {mfa, %{caller: nil}} <- calls,
        Map.has_key?(functions, mfa),
        into: MapSet.new(),
        do: mfa
  end
end
