defmodule Mix.Tasks.Compile.Unused do
  use Mix.Task.Compiler

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

  @recursive true

  @built_ins [
    __info__: 1,
    __struct__: 0,
    __struct__: 1,
    __impl__: 1,
    module_info: 0,
    module_info: 1,
    behaviour_info: 1
  ]

  @options [
    exit_status: :boolean,
    quiet: :boolean,
    compile: :boolean
  ]

  @impl true
  def run(argv) do
    {:ok, _} = MixUnused.start_link()

    Mix.Task.Compiler.after_compiler(:app, &after_compiler(&1, argv))

    tracers = Code.get_compiler_option(:tracers)
    Code.put_compiler_option(:tracers, [MixUnused | tracers])

    {:ok, []}
  end

  defp after_compiler({status, diagnostics}, _) do
    unused = all_modules(Mix.Project.config()[:app]) -- MixUnused.get_calls()

    messages =
      for {m, f, a} <- unused do
        %Mix.Task.Compiler.Diagnostic{
          compiler_name: "unused",
          message: "#{inspect(m)}.#{f}/#{a} is unused",
          severity: :hint,
          position: nil,
          file: "unknown"
        }
      end

    {status, messages ++ diagnostics}
  end

  defp all_modules(app) do
    _ = Application.unload(app)
    :ok = Application.load(app)

    # Check exported functions without loading modules as this could cause
    # unexpected behaviours in case of `on_load` callbacks
    app
    |> Application.spec(:modules)
    |> Enum.flat_map(fn mod ->
      with path when is_list(path) <- :code.which(mod),
           beam = File.read!(path),
           {:ok, {^mod, [{:exports, exports}]}} <- :beam_lib.chunks(beam, [:exports]) do
        for {name, arity} <- exports,
            {name, arity} not in @built_ins,
            do: {mod, name, arity}
      else
        _ -> []
      end
    end)
  end
end
