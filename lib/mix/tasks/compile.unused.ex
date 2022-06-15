defmodule Mix.Tasks.Compile.Unused do
  use Mix.Task.Compiler

  @shortdoc "Find unused public functions"

  @moduledoc ~S"""
  Compile project and find uncalled public functions.

  ### Warning

  This isn't perfect solution and this will not find dynamic calls in form of:

      apply(mod, func, args)

  So this mean that, for example, if you have custom `child_spec/1` definition
  then this will return such function as unused even when you are using that
  indirectly in your supervisor.

  ## Configuration

  You can define used functions by adding pattern in `unused: [ignored: [⋯]]`
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

  ### Patterns

  `unused` patterns are similar to the match specs from Erlang, but extends
  their API to be much more flexible. Simplest possible patter is to match
  exactly one function, which mean that we use 3-ary tuple with module,
  function name, and arity as respective elements, ex.:

      [{Foo, :bar, 1}]

  This will match function `Foo.bar/1`, however often we want to use more
  broad patterns, in such case there are few tricks we can use. First is
  to use `:_` which will mean "wildcard" aka any value will match, ex.:

      [{:_, :child_spec, 1}]

  Will ignore all functions `child_spec/1` in your application (you probably
  should add it, as `unused` is not able to notice that this function is used
  even if it is used in any supervisor, as it will be dynamic call).

  In additional to wildcard matches, which isn't often what we really want, we
  can use regular expressions for module and function name or range for arity:

      [
        {:_, ~r/^__.+__\??$/, :_},
        {~r/^MyAppWeb\..*Controller/, :_, 2},
        {MyApp.Test, :foo, 1..2}
      ]

  To make the ignore specification list less verbose there is also option to
  omit last `:_`, i.e.: `{Foo, :bar, :_}` is the same as `{Foo, :bar}`, if you
  want to ignore whole module, then you can just use `Foo` (it also works for
  regular expressions).

  To ignore warnings about unused structs you need to use "special" syntax in
  form of `{StructModule, :__struct__, 0}`.

  The pattern list can also take the predicate function which can be either
  unary or binary function. First argument will be `t:mfa/0` and second argument
  (in case of the binary function) will be `t:MixUnused.Meta.t/0`.

  ### Documentation metadata

  Functions that have `export: true` in their metadata will be automatically
  treated as exports for usage by external parties and will not be marked as
  unused.

  ## Options

  - `--severity` - severity of the reported messages, defaults to `hint`.
    Other allowed levels are `information`, `warning`, and `error`.
  - `--warnings-as-errors` - if the `severity` is set to `:warning` and there is
    any report, then fail compilation with exit code `1`.
  """

  alias Mix.Task.Compiler.Diagnostic

  @recursive true

  @manifest "unused.manifest"

  alias MixUnused.Tracer
  alias MixUnused.Filter
  alias MixUnused.Exports

  @impl true
  def run(argv) do
    {:ok, _pid} = Tracer.start_link()

    mix_config = Mix.Project.config()
    config = MixUnused.Config.build(argv, Keyword.get(mix_config, :unused, []))
    tracers = Code.get_compiler_option(:tracers)

    [manifest] = manifests()

    Mix.Task.Compiler.after_compiler(
      :app,
      &after_compiler(&1, mix_config[:app], tracers, config, manifest)
    )

    Code.put_compiler_option(:tracers, [Tracer | tracers])

    {:ok, []}
  end

  @impl true
  def manifests, do: [Path.join(Mix.Project.manifest_path(), @manifest)]

  @impl true
  def clean, do: Enum.each(manifests(), &File.rm/1)

  defp after_compiler({status, diagnostics}, app, tracers, config, manifest) do
    # Cleanup tracers after compilation
    Code.put_compiler_option(:tracers, tracers)

    data =
      Tracer.get_data()
      |> update_manifest(manifest)

    all_functions =
      app
      |> Exports.application()
      |> Filter.reject_matching(config.ignore)

    error_on_messages =
      config.severity == :error or
        (config.severity == :warning and config.warnings_as_errors)

    config.checks
    |> MixUnused.Analyze.analyze(data, all_functions, config)
    |> filter_files_in_paths(config.paths)
    |> Enum.sort_by(&{&1.file, &1.position, &1.details.mfa})
    |> limit_results(config.limit)
    |> tap_all(&print_diagnostic/1)
    |> case do
      [] ->
        {status, diagnostics}

      messages when error_on_messages ->
        {:error, messages ++ diagnostics}

      messages ->
        {status, messages ++ diagnostics}
    end
  end

  defp update_manifest(data, manifest) do
    cache =
      case File.read(manifest) do
        {:ok, data} -> :erlang.binary_to_term(data)
        _ -> %{}
      end

    {version, cache} = normalise_cache(cache)

    data = Map.merge(cache, data)

    _ = File.mkdir_p(Mix.Project.manifest_path())

    with {:error, error} <-
           File.write(manifest, :erlang.term_to_binary({version, data})) do
      Mix.shell().error("Cannot write manifest: #{inspect(error)}")
    end

    data
  end

  defp normalise_cache({:v0, map}) when is_map(map), do: {:v0, map}
  defp normalise_cache(map) when is_map(map), do: {:v0, map}
  defp normalise_cache(_), do: %{}

  defp filter_files_in_paths(diags, nil), do: diags

  defp filter_files_in_paths(diags, paths) do
    Enum.filter(diags, fn %Diagnostic{file: file} ->
      [root | _] = file |> Path.relative_to_cwd() |> Path.split()
      root in paths
    end)
  end

  defp limit_results(diags, nil), do: diags
  defp limit_results(diags, limit), do: Enum.take(diags, limit)

  defp print_diagnostic(%Diagnostic{details: %{mfa: {_, :__struct__, 1}}}),
    do: nil

  defp print_diagnostic(diag) do
    file = Path.relative_to_cwd(diag.file)

    Mix.shell().info([
      level(diag.severity),
      diag.message,
      "\n    ",
      file,
      ?:,
      Integer.to_string(diag.position),
      "\n"
    ])
  end

  # Elixir < 1.12 do not have tap, so we provide custom implementation
  defp tap_all(list, fun) do
    Enum.each(list, fun)

    list
  end

  defp level(level), do: [:bright, color(level), "#{level}: ", :reset]

  defp color(:error), do: :red
  defp color(:warning), do: :yellow
  defp color(_), do: :blue
end
