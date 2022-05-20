defmodule MixUnused.Analyzers.Unreachable.Usages.SupervisorDiscovery do
  @moduledoc """
  Discovers the GenServers started by Supervisor.
  """

  alias MixUnused.Analyzers.Unreachable.Usages.Helpers.Source

  @behaviour MixUnused.Analyzers.Unreachable.Usages

  @impl true
  def discover_usages(exports: exports) do
    "supervisor.ex"
    |> Source.read_sources_with_suffix(exports)
    |> Enum.flat_map(&analyze(&1, exports))
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
