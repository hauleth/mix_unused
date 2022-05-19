defmodule MixUnused.Analyzers.Unreachable.Usages.PhoenixControllersDiscovery do
  @moduledoc """
  Discovers the controllers used by the Phoenix router.
  """

  alias MixUnused.Analyzers.Unreachable.Usages.DiscoveryHelpers

  @behaviour MixUnused.Analyzers.Unreachable.Usages

  @methods [
    :get,
    :forward,
    :options,
    :patch,
    :post,
    :put
  ]

  @impl true
  def discover_usages(exports: exports) do
    "router.ex"
    |> DiscoveryHelpers.read_sources_with_suffix(exports)
    |> Enum.flat_map(&analyze(&1, exports))
  end

  defp analyze(ast, exports) do
    ast
    |> Macro.prewalker()
    |> Enum.flat_map(&controllers(&1, exports))
  end

  defp controllers({method, _, [_path, {:__aliases__, _, atoms}, f]}, functions)
       when method in @methods do
    module_alias = Enum.join(atoms, ".")
    resolve_mfa(functions, module_alias, f)
  end

  defp controllers(_node, _functions), do: []

  defp resolve_mfa(functions, module_alias, function) do
    for {{m, ^function, _a} = mfa, _meta} <- functions,
        m |> Atom.to_string() |> String.ends_with?(module_alias),
        do: mfa
  end
end
