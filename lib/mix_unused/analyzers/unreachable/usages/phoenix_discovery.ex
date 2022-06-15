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

  alias MixUnused.Analyzers.Unreachable.Usages.Context
  alias MixUnused.Analyzers.Unreachable.Usages.Helpers.Aliases
  alias MixUnused.Analyzers.Unreachable.Usages.Helpers.Source

  @behaviour MixUnused.Analyzers.Unreachable.Usages

  @http_methods [
    :connect,
    :delete,
    :forward,
    :get,
    :head,
    :options,
    :patch,
    :post,
    :trace
  ]

  @impl true
  def discover_usages(%Context{exports: exports}) do
    for source <- Source.read_sources_with_suffix("router.ex", exports),
        mfa <- analyze(source),
        uniq: true,
        do: mfa
  end

  defp analyze(ast) do
    aliases = Aliases.new(ast)

    for node <- Macro.prewalker(ast),
        {m, f, a} <- functions_called_by_router(node),
        {:ok, m} <- [Aliases.resolve(aliases, m)],
        do: {m, f, a}
  end

  defp functions_called_by_router(ast) do
    case ast do
      {method, _, [_path, module, f | _]}
      when method in @http_methods and is_atom(f) ->
        [{module, f, 2}]

      {:plug, _, [module | _]} ->
        [{module, :init, 1}, {module, :call, 2}]

      _ ->
        []
    end
  end
end
