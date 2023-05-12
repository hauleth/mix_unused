defmodule MixUnused.Analyzers.Unused do
  @moduledoc false

  @behaviour MixUnused.Analyze

  @impl true
  def message, do: "is unused"

  @impl true
  def analyze(data, possibly_uncalled) do
    graph = Graph.new(type: :directed)

    graph =
      for {m, calls} <- data,
          {mfa, %{caller: {f, a}}} <- calls,
          reduce: graph do
        acc ->
          Graph.add_edge(acc, {m, f, a}, mfa)
      end

    called =
      Graph.Reducers.Dfs.reduce(graph, MapSet.new(), fn v, acc ->
        if v in acc do
          {:skip, acc}
        else
          edges = Graph.edges(graph, v)

          called? =
            Enum.any?(edges, fn %{v1: caller} ->
              caller in acc or
                Enum.all?(possibly_uncalled, fn {mfa, _} ->
                  mfa != caller
                end)
            end)

          acc = if called?, do: mark_as_called(v, acc, graph), else: acc

          {:next, acc}
        end
      end)

    for {mfa, meta} = call <- possibly_uncalled,
        not Map.get(meta.doc_meta, :export, false),
        mfa not in called,
        into: %{},
        do: call
  end

  # Mark the given mfa as called. Then fetch a list
  # of all mfas this calls and recursively mark them
  # as called too.
  defp mark_as_called(mfa, acc, graph) do
    if mfa in acc do
      acc
    else
      acc = MapSet.put(acc, mfa)

      graph
      |> Graph.out_neighbors(mfa)
      |> Enum.reduce(acc, fn neighbor, acc ->
        mark_as_called(neighbor, acc, graph)
      end)
    end
  end
end
