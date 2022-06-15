defmodule MixUnused.Analyzers.Unreachable.Usages.AbsintheDiscovery do
  @moduledoc """
  Discovers some components used dynamically by [Absinthe](http://absinthe-graphql.org/).

  It analyses all the modules exposing the function `__absinthe_function__` (schemas, type definitions, etc.)
  looking for the following patterns:
  * `middleware Module, ...`: consider the function `Module.call/2` as used.

  It assumes that the `__absinthe_function__` functions are used too.
  This could be wrong if the related schemas are not referred anywhere.
  """

  alias MixUnused.Analyzers.Unreachable.Usages.Context
  alias MixUnused.Analyzers.Unreachable.Usages.Helpers.Aliases
  alias MixUnused.Analyzers.Unreachable.Usages.Helpers.Source
  alias MixUnused.Meta

  @behaviour MixUnused.Analyzers.Unreachable.Usages

  @impl true
  def discover_usages(%Context{exports: exports}) do
    for {{_m, :__absinthe_function__, _a} = absinthe_mfa, %Meta{file: file}} <-
          exports,
        source <- [Source.read_source(file)],
        mfa <- [absinthe_mfa | analyze(source)],
        uniq: true,
        do: mfa
  end

  defp analyze(ast) do
    aliases = Aliases.new(ast)

    for {:middleware, _, [module | _args]} <- Macro.prewalker(ast),
        {:ok, module} <- [Aliases.resolve(aliases, module)],
        do: {module, :call, 2}
  end
end
