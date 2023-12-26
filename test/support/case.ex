# credo:disable-for-this-file Credo.Check.Readability.Specs
defmodule MixUnused.Case do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      import unquote(__MODULE__)
    end
  end

  def in_project(opts \\ [], fun) do
    loaded_apps_before =
      Enum.into(Application.loaded_applications(), MapSet.new(), fn {app, _, _} ->
        app
      end)

    deps_path = Mix.Project.deps_path()

    %{name: name, file: file} = Mix.Project.pop()

    tmp_path =
      Path.absname("tmp/#{:erlang.unique_integer(~w/positive monotonic/a)}")

    app_name = "test_project_#{:erlang.unique_integer(~w/positive monotonic/a)}"
    app = String.to_atom(app_name)
    project = %{app: app, path: Path.join(tmp_path, app_name)}
    opts = Keyword.put(opts, :deps_path, deps_path)
    shell = Mix.shell()
    Mix.shell(Mix.Shell.Process)

    try do
      File.rm_rf(project.path)

      Mix.Task.clear()
      File.mkdir_p!(project.path)
      reinitialize(project, opts)

      Mix.Project.in_project(app, project.path, [], fn _module ->
        fun.(project)
      end)
    after
      Mix.Project.push(name, file)

      Mix.shell(shell)

      Application.loaded_applications()
      |> MapSet.new(fn {app, _, _} -> app end)
      |> MapSet.difference(loaded_apps_before)
      |> Enum.each(&Application.unload/1)

      File.rm_rf(tmp_path)
    end
  end

  def compile(opts \\ []) do
    options = Code.compiler_options()

    try do
      Code.put_compiler_option(:warnings_as_errors, false)
      Code.put_compiler_option(:ignore_module_conflict, true)
      Code.put_compiler_option(:ignore_already_consolidated, true)

      run_task("compile", opts)
    after
      Code.compiler_options(options)
    end
  end

  def run_task(task, args \\ []) do
    ref = make_ref()

    ExUnit.CaptureIO.capture_io(fn ->
      Mix.Task.clear()
      send(self(), {ref, Mix.Task.rerun(task, args)})
    end)

    receive do
      {^ref, result} ->
        {diagnostics, errors} =
          case result do
            :ok -> {[], []}
            {:ok, result} -> {result, []}
            {:error, errors} -> {[], errors}
          end

        output =
          Stream.repeatedly(fn ->
            receive do
              {:mix_shell, :info, msg} -> msg
            after
              0 -> nil
            end
          end)
          |> Enum.take_while(&(not is_nil(&1)))
          |> to_string

        %{output: output, diagnostics: diagnostics, errors: errors}
    after
      0 -> raise("result not received")
    end
  end

  defp reinitialize(project, opts) do
    File.write!(
      Path.join(project.path, "mix.exs"),
      mix_exs(project, opts)
    )
  end

  defp mix_exs(project, opts) do
    lib = Path.join(File.cwd!(), opts[:source])

    """
    defmodule #{Macro.camelize(to_string(project.app))}.MixProject do
      use Mix.Project

      def project do
        [
          app: :#{project.app},
          version: "0.1.0",
          elixir: "~> 1.10",
          elixirc_paths: #{inspect([lib])},
          elixirc_options: [docs: true],
          deps_path: #{inspect(opts[:deps_path])},
          lockfile: #{inspect(unquote(Path.join(File.cwd!(), "mix.lock")))},
          start_permanent: Mix.env() == :prod,
          deps: deps(),
          compilers: #{inspect(Keyword.get(opts, :compilers, [:unused]))} ++ Mix.compilers()
        ] ++ #{inspect(Keyword.get(opts, :project_opts, []))}
      end

      def application do
        [
          extra_applications: [:logger]
        ]
      end

      defp deps do
        #{inspect([{:mix_unused, path: unquote(File.cwd!())} | Keyword.get(opts, :deps, [])])}
      end
    end
    """
  end
end
