defmodule MixUnused.Analyzers.Unreachable.Usages.PhoenixDiscovery do
  @moduledoc """
  Discovers some resources used by the Phoenix router:
  * controllers;
  * plugs declared in the pipelines.

  Caveats:
  * it does not check if a pipeline is actually used;
  * it does not resolve controller aliases properly if they are relative to the current scope.
  """

  alias MixUnused.Analyzers.Unreachable.Usages.Helpers.Aliases
  alias MixUnused.Analyzers.Unreachable.Usages.Helpers.Source

  @behaviour MixUnused.Analyzers.Unreachable.Usages

  @http_methods [
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

    for node <- Macro.prewalker(ast) do
      case node do
        {method, _, [_path, {:__aliases__, _, atoms}, f]}
        when method in @http_methods and is_atom(f) ->
          module = Aliases.resolve(aliases, atoms)
          [{module, f, 2}]

        {:plug, _, [{:__aliases__, _, atoms} | _]} ->
          module = Aliases.resolve(aliases, atoms)
          [{module, :init, 1}, {module, :call, 2}]

        _ ->
          []
      end
    end
    |> List.flatten()
  end
end
