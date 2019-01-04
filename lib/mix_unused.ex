defmodule Mix.Tasks.Unused do
  @moduledoc """
  Documentation for MixUnused.
  """

  @manifest "compile.elixir"
  @built_ins [
    __info__: 1,
    module_info: 0,
    module_info: 1
  ]

  import Mix.Compilers.Elixir,
    only: [read_manifest: 2, source: 1, module: 1]

  @doc """
  Hello world.

  ## Examples

      iex> MixUnused.hello()
      :world

  """
  def run(_) do
    data = for man <- manifests([]), entry <- read_manifest(man, ""), do: entry

    excluded =
      Mix.Project.config()
      |> Keyword.get(:xref, [])
      |> Keyword.get(:used, [])
      |> MapSet.new()

    {public, called} = group(data)

    public
    |> MapSet.difference(excluded)
    |> MapSet.difference(called)
    |> MapSet.to_list()
    |> print()
  end

  defp print([]), do: nil

  defp print(entries) do
    for func <- entries do
      Mix.shell().info([:red, "function ", display_func(func), " is unused"])
    end
  end

  defp display_func({mod, name, arity}) do
    [format_module(mod), ?., Atom.to_string(name), ?/, Integer.to_string(arity)]
  end

  defp format_module(mod), do: :lists.join(?., mod |> Module.split())

  defp group(items, agg \\ {MapSet.new(), MapSet.new()})
  defp group([], aggregate), do: aggregate

  defp group([module(module: mod) | rest], {public, called}) do
    behaviours = mod.module_info(:attributes) |> Keyword.get(:behaviour, [])

    callbacks =
      for behaviour <- behaviours,
          function <- behaviour.behaviour_info(:callbacks),
          do: function

    functions =
      for {name, arity} <- mod.module_info(:exports),
          {name, arity} not in @built_ins,
          {name, arity} not in callbacks,
          into: MapSet.new(),
          do: {mod, name, arity}

    group(rest, {MapSet.union(public, functions), called})
  end

  defp group(
         [source(runtime_dispatches: runtime, compile_dispatches: compile) | rest],
         {public, called}
       ) do
    functions =
      for {module, functions} <- Enum.concat(runtime, compile),
          {{name, arity}, _} <- functions,
          into: MapSet.new(),
          do: {module, name, arity}

    group(rest, {public, MapSet.union(called, functions)})
  end

  defp manifests(opts) do
    siblings =
      if opts[:include_siblings] do
        for %{scm: Mix.SCM.Path, opts: opts} <- Mix.Dep.cached(),
            opts[:in_umbrella],
            do: Path.join([opts[:build], ".mix", @manifest])
      else
        []
      end

    [Path.join(Mix.Project.manifest_path(), @manifest) | siblings]
  end
end
