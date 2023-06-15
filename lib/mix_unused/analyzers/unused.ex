defmodule MixUnused.Analyzers.Unused do
  @moduledoc false

  @behaviour MixUnused.Analyze

  @impl true
  def message, do: "is unused"

  @impl true
  def analyze(data, possibly_uncalled) do
    graph = Graph.new(type: :directed)

    uncalled_funcs = MapSet.new(possibly_uncalled, fn {mfa, _} -> mfa end)

    graph =
      for {m, calls} <- data,
          {mfa, %{caller: {f, a}}} <- calls,
          reduce: graph do
        acc ->
          Graph.add_edge(acc, {m, f, a}, mfa)
      end

    for {mfa, meta} = call <- possibly_uncalled,
        not Map.get(meta.doc_meta, :export, false),
        reaching = Graph.reaching_neighbors(graph, [mfa]),
        Enum.all?(reaching, fn caller -> caller in uncalled_funcs end),
        into: %{},
        do: call
  end
end
