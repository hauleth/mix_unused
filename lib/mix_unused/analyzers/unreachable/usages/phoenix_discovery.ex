defmodule MixUnused.Analyzers.Unreachable.Usages.PhoenixDiscovery do
  @moduledoc """
  Discovers the controllers used by the Phoenix router.
  """

  alias MixUnused.Analyzers.Unreachable.Usages.Helpers.Aliases
  alias MixUnused.Analyzers.Unreachable.Usages.Helpers.Source

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
    |> Source.read_sources_with_suffix(exports)
    |> Enum.flat_map(&analyze/1)
  end

  defp analyze(ast) do
    aliases = Aliases.new(ast)

    for node <- Macro.prewalker(ast), reduce: [] do
      state ->
        case node do
          {method, _, [_path, {:__aliases__, _, atoms}, f]}
          when method in @methods and is_atom(f) ->
            module = Aliases.resolve(aliases, atoms)
            [{module, f, 2} | state]

          _ ->
            state
        end
    end
  end
end
