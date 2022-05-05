defmodule MixUnused.Analyzers.Unused do
  @moduledoc false

  alias MixUnused.Analyzers.Calls
  alias MixUnused.Meta

  @behaviour MixUnused.Analyze

  @impl true
  def message, do: "is unused"

  @impl true
  def analyze(data, functions, _config \\ nil) do
    possibly_uncalled =
      Map.filter(functions, &match?({_mfa, %Meta{callback: false}}, &1))

    graph = Calls.calls_graph(data, possibly_uncalled)

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
