defmodule MixUnused.Analyzers.Unreachable.Usages.SupervisorDiscovery do
  @moduledoc """
  Discovers the GenServers started by Supervisor.

  The current implementation is quite naive: it looks at any file named _supervisor.ex_,
  searches all the referred modules and considers as used all the functions related with
  the `GenServer` behaviour that exist in the referred modules.

  For instance, let's assume we have the following supervisor:

      defmodule App.Supervisor do

        use Supervisor

        def start_link(opts) do
          Supervisor.start_link(__MODULE__, opts)
        end

        def init(_) do
          children = [
            App.Cache
          ]

          opts = [strategy: :one_for_one, name: __MODULE__]
          Supervisor.init(children, opts)
        end
      end

  The discovery module finds a reference to `App.Cache`, sees that the functions `App.Cache.init/1`, `App.Cache.handle_call/3`, etc. exist, so considers them as used.

  Caveats:
  * it currently does not resolve aliases, for this reason the `Supervisor` itself is not detected in the example above.
  """

  alias MixUnused.Analyzers.Unreachable.Usages.Context
  alias MixUnused.Analyzers.Unreachable.Usages.Helpers.Source

  @behaviour MixUnused.Analyzers.Unreachable.Usages

  @impl true
  def discover_usages(%Context{exports: exports}) do
    "supervisor.ex"
    |> Source.read_sources_with_suffix(exports)
    |> Enum.flat_map(&analyze(&1, exports))
    |> Enum.uniq()
  end

  defp analyze(ast, exports) do
    ast
    |> Macro.prewalker()
    |> Enum.flat_map(&genservers/1)
    |> Enum.filter(&Map.has_key?(exports, &1))
  end

  defp genservers({:__aliases__, _, atoms}) do
    module = Module.concat(atoms)

    [
      {module, :init, 1},
      {module, :handle_cast, 2},
      {module, :handle_info, 2},
      {module, :handle_call, 3},
      {module, :handle_continue, 2},
      {module, :terminate, 2},
      {module, :code_change, 2},
      {module, :child_spec, 1},
      {module, :start_link, 1}
    ]
  end

  defp genservers(_node), do: []
end
