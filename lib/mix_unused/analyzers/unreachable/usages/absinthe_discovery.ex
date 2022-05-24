defmodule MixUnused.Analyzers.Unreachable.Usages.AbsintheDiscovery do
  @moduledoc """
  Discovers some components used dynamically by [Absinthe](http://absinthe-graphql.org/).

  It analyses all the modules exposing the function `__absinthe_function__` (schemas, type definitions, etc.)
  looking for the following patterns:
  * `middleware Module, ...`: consider the function `Module.call/2` as used.

  It assumes that the `__absinthe_function__` functions are used too.
  This could be wrong if the related schemas are not referred anywhere.
  """

  alias MixUnused.Analyzers.Unreachable.Usages.Helpers.Aliases
  alias MixUnused.Analyzers.Unreachable.Usages.Helpers.Source
  alias MixUnused.Meta

  @behaviour MixUnused.Analyzers.Unreachable.Usages

  @impl true
  def discover_usages(exports: exports) do
    # TODO: it should start from the schemas used in the routers
    for {{_m, :__absinthe_function__, _a} = mfa, %Meta{file: file}} <- exports do
      detected_usages = file |> Source.read_source() |> analyze()
      [mfa | detected_usages]
    end
    |> List.flatten()
  end

  defp analyze(ast) do
    aliases = Aliases.new(ast)

    middlewares =
      for {:middleware, _, [{:__aliases__, _, atoms} | _args]} <-
            Macro.prewalker(ast) do
        {Aliases.resolve(aliases, atoms), :call, 2}
      end

    Enum.uniq(middlewares)
  end
end
