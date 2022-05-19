defmodule MixUnused.Debug do
  @moduledoc false

  @spec log_graph(Graph.t()) :: Graph.t()
  def log_graph(graph) do
    if debug?() do
      write_edgelist(graph)
      write_binary(graph)
    end

    graph
  end

  defp write_edgelist(graph) do
    {:ok, content} = Graph.to_edgelist(graph)
    path = Path.join(Mix.Project.manifest_path(), "graph.txt")
    File.write!(path, content)

    Mix.shell().info([
      IO.ANSI.yellow_background(),
      "Serialized edgelist to #{path}",
      :reset
    ])
  end

  defp write_binary(graph) do
    content = :erlang.term_to_binary(graph)
    path = Path.join(Mix.Project.manifest_path(), "graph.bin")
    File.write!(path, content)

    Mix.shell().info([
      IO.ANSI.yellow_background(),
      "Serialized graph to #{path}",
      IO.ANSI.reset(),
      IO.ANSI.light_black(),
      "\n\nTo use it from iex:\n",
      ~s{
        Mix.install([libgraph: ">= 0.0.0"])
        graph = "#{path}" |> File.read!() |> :erlang.binary_to_term()
        Graph.info(graph)
      },
      IO.ANSI.reset()
    ])
  end

  @spec debug(v, (v -> term)) :: v when v: var
  def debug(value, fun) do
    if debug?(), do: fun.(value)
    value
  end

  defp debug?, do: System.get_env("MIX_UNUSED_DEBUG") == "true"
end
