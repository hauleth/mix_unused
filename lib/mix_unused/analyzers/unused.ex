defmodule MixUnused.Analyzers.Unused do
  @moduledoc false

  alias MixUnused.Meta

  @behaviour MixUnused.Analyze

  @impl true
  def message, do: "is unused"

  @impl true
  def analyze(data, functions, _config \\ nil) do
    graph = Graph.new(type: :directed)

    possibly_uncalled =
      for {_mfa, %Meta{callback: false}} = call <- functions,
          into: %{},
          do: call

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
          {:halt, acc}
        else
          edges = Graph.edges(graph, v)

          called? =
            Enum.any?(edges, fn %{v1: caller} ->
              caller in acc or
                Enum.all?(possibly_uncalled, fn {mfa, _} ->
                  mfa != caller
                end)
            end)

          acc = if called?, do: MapSet.put(acc, v), else: acc

          {:next, acc}
        end
      end)

    for {mfa, meta} = call <- possibly_uncalled,
        not Map.get(meta.doc_meta, :export, false),
        mfa not in called,
        into: %{},
        do: call
  end
end
