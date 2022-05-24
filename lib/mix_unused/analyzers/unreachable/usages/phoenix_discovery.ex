defmodule MixUnused.Analyzers.Unreachable.Usages.PhoenixDiscovery do
  @moduledoc """
  Discovers some components used dynamically by the [Phoenix framework](https://www.phoenixframework.org/).

  ## Controllers

  It reads the content of any file named _router.ex_ looking for calls in the form `method Controller, :name` (where `method` is `get`, `post`, etc.), then it considers all the referred functions (i.e. `Controller.name/2`) as used.

  It properly resolves aliases, but at this time it does not recognise "scoped" controllers; so if you have something like:

      scope "/", App do
        get "/", PageController, :index
      end

  You should use the full module name or an alias:

      scope "/" do
        get "/", App.PageController, :index
      end

  ## Plugs

  It reads the content of any file named _router.ex_ looking for calls in the form `plug Module, ...`, then it considers all the related functions (i.e. `Module.init/1` and `Module.call/2`) as used.

  Note: generally plugs are defined inside pipelines, but the discovery module currently does not check if a pipeline is actually used.
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
