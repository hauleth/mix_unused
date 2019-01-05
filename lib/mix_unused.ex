defmodule Mix.Tasks.Unused do
  use Mix.Task

  def foo, do: nil

  @shortdoc "Find unused public functions"

  @moduledoc """
  Compile project and find uncalled public functions.

  ### Warning

  This isn't perfect solution and this will not find dynamic calls in form of:

      apply(mod, func, args)

  So this mean that, for example, if you have custom `child_spec/1` definition
  then `mix unused` can return such function as unused even when you are using
  that indirectly in your supervisor.

  ## Configuration

  You can define used functions by adding `mfa` in `unused: [ignored: [⋯]]`
  in your project configuration:

      def project do
        [
          # ⋯
          unused: [
            ignore: [
              {MyApp.Foo, :child_spec, 1}
            ]
          ],
          # ⋯
        ]
      end

  ## Options

  - `--exit-status` (default: false) - returns 1 if there are any unused function
    calls
  - `--quiet` (default: false) - do not print output
  - `--compile` (default: true) - compile project before running
  """

  @manifest "compile.elixir"
  @built_ins [
    __info__: 1,
    module_info: 0,
    module_info: 1,
    behaviour_info: 1
  ]

  import Mix.Compilers.Elixir, only: [read_manifest: 2, source: 1, module: 1]

  @options [
    exit_status: :boolean,
    quiet: :boolean,
    compile: :boolean
  ]

  def run(argv) do
    {options, _rest} = OptionParser.parse!(argv, strict: @options)

    original_shell = Mix.shell()

    if options[:quiet], do: Mix.shell(Mix.Shell.Quiet)

    if Keyword.get(options, :compile, true), do: Mix.Task.run("compile")

    Mix.Task.reenable("unused")

    data = for man <- manifests([]), entry <- read_manifest(man, ""), do: entry

    ignored =
      Mix.Project.config()
      |> Keyword.get(:unused, [])
      |> Keyword.get(:ignore, [])
      |> MapSet.new()

    {public, called} = group(data)

    public
    |> MapSet.difference(ignored)
    |> MapSet.difference(called)
    |> MapSet.to_list()
    |> print(options)

    Mix.shell(original_shell)
  end

  @spec print(entries :: [mfa()], opts :: keyword()) :: :ok
  defp print([], _opts), do: :ok

  defp print(entries, opts) do
    for func <- entries do
      Mix.shell().info([:red, "function ", display_func(func), " is unused"])
    end

    if Keyword.get(opts, :exit_status, false), do: :erlang.halt(1)

    :ok
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
