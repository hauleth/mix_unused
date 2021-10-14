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

  In additiona to wildcard matches, which isn't often what we really want, we
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

  ## Options

  - `severity` - severity of the reported messages, defaults to `hint`.
    Other allowed levels are `information`, `warning`, and `error`.
  """

  alias Mix.Task.Compiler.Diagnostic

  @recursive true

  @manifest "unused.manifest"

  @options [
    severity: :string,
    warnings_as_errors: :boolean
  ]

  alias MixUnused.Tracer
  alias MixUnused.Filter
  alias MixUnused.Exports

  @impl true
  def run(argv) do
    {opts, _rest, _other} = OptionParser.parse(argv, strict: @options)
    {:ok, _pid} = Tracer.start_link()

    [manifest] = manifests()

    tracers = Code.get_compiler_option(:tracers)
    Mix.Task.Compiler.after_compiler(:app, &after_compiler(&1, tracers, opts, manifest))
    Code.put_compiler_option(:tracers, [Tracer | tracers])

    {:ok, []}
  end

  @impl true
  def manifests do
    [Path.join(Mix.Project.manifest_path(), @manifest)]
  end

  @impl true
  def clean do
    Enum.each(manifests(), &File.rm/1)
  end

  defp after_compiler({status, diagnostics}, tracers, opts, manifest) do
    # Cleanup tracers after compilation
    Code.put_compiler_option(:tracers, tracers)

    cache =
      case File.read(manifest) do
        {:ok, data} -> :erlang.binary_to_term(data)
        _ -> %{}
      end

    config = Mix.Project.config()
    data = Map.merge(cache, Tracer.get_data())
    calls = Enum.flat_map(data, fn {_key, value} -> value end)
    severity = Keyword.get(opts, :severity, "hint") |> severity()
    warnings_as_errors = Keyword.get(opts, :warnings_as_errors, false)

    File.write!(manifest, :erlang.term_to_binary(data))

    unused =
      config[:app]
      |> all_functions()
      |> Map.drop(calls)
      |> Filter.reject_matching(ignores(config))
      |> Enum.sort()

    :ok = Tracer.stop()

    messages =
      for {{m, f, a}, meta} = desc <- unused do
        %Diagnostic{
          compiler_name: "unused",
          message: message(desc),
          severity: severity,
          position: meta.line,
          file: meta.file,
          details: %{
            mfa: {m, f, a},
            signature: meta.signature
          }
        }
        |> _tap(&print_diagnostic/1)
      end

    case {messages, severity, warnings_as_errors} do
      {[], _, _} ->
        {status, diagnostics}

      {messages, :error, _} ->
        {:error, messages ++ diagnostics}

      {messages, :warning, true} ->
        {:error, messages ++ diagnostics}

      {messages, _, _} ->
        {status, messages ++ diagnostics}
    end
  end

  defp all_functions(app) do
    _ = Application.unload(app)
    :ok = Application.load(app)

    Application.spec(app, :modules)
    |> Enum.flat_map(&Exports.fetch/1)
    |> Map.new()
  end

  defp ignores(config) do
    config
    |> Keyword.get(:unused, [])
    |> Keyword.get(:ignore, [])
  end

  defp severity("hint"), do: :hint
  defp severity("info"), do: :information
  defp severity("information"), do: :information
  defp severity("warn"), do: :warning
  defp severity("warning"), do: :warning
  defp severity("error"), do: :error

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

  defp message({{_, :__struct__, 0}, meta}) do
    "#{meta.signature} is unused"
  end

  defp message({{m, f, a}, _meta}) do
    "#{inspect(m)}.#{f}/#{a} is unused"
  end

  # Elixir < 1.12 do not have tap, so we provide custom implementation
  defp _tap(val, fun) do
    fun.(val)

    val
  end

  defp level(level), do: [:bright, color(level), "#{level}: ", :reset]

  defp color(:error), do: :red
  defp color(:warning), do: :yellow
  defp color(_), do: :blue
end
