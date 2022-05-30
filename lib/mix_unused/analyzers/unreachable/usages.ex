defmodule MixUnused.Analyzers.Unreachable.Usages do
  @moduledoc """
  Provides the starting points for the [Unreachable](`MixUnused.Analyzers.Unreachable`) analyzer.
  """

  alias MixUnused.Analyzers.Unreachable.Config
  alias MixUnused.Debug
  alias MixUnused.Exports
  alias MixUnused.Filter

  @type context :: [
          exports: Exports.t()
        ]

  @doc """
  Called during the analysis to search potential used functions.

  It receives the map of all the exported functions and returns
  the list of found functions.
  """
  @callback discover_usages(context()) :: [mfa()]

  @default_discoveries [
    MixUnused.Analyzers.Unreachable.Usages.AbsintheDiscovery,
    MixUnused.Analyzers.Unreachable.Usages.AmqpxConsumersDiscovery,
    MixUnused.Analyzers.Unreachable.Usages.HttpMockPalDiscovery,
    MixUnused.Analyzers.Unreachable.Usages.PhoenixDiscovery,
    MixUnused.Analyzers.Unreachable.Usages.SupervisorDiscovery,
    MixUnused.Analyzers.Unreachable.Usages.VmstatsDiscovery
  ]

  @spec usages(Config.t(), Exports.t()) :: [mfa()]
  def usages(
        %Config{
          usages: usages,
          usages_discovery: usages_discovery
        },
        exports
      ) do
    modules =
      Enum.concat(
        declared_usages(usages, exports),
        discovered_usages(usages_discovery ++ @default_discoveries, exports)
      )

    Debug.debug(modules, &debug/1)
  end

  @spec declared_usages([Filter.pattern()], Exports.t()) :: [mfa()]
  defp declared_usages(patterns, exports) do
    Filter.filter_matching(exports, patterns) |> Map.keys()
  end

  @spec discovered_usages([module()], Exports.t()) :: [mfa()]
  defp discovered_usages(modules, exports) do
    for module <- modules do
      [
        # the module is itself an used module since it
        # could call functions created specifically for it
        {module, :discover_usages, 1}
        | apply(module, :discover_usages, [[exports: exports]])
      ]
    end
    |> List.flatten()
  end

  defp debug(modules) do
    Mix.shell().info([
      IO.ANSI.light_black(),
      "Found usages: \n",
      modules
      |> Enum.sort()
      |> Enum.map_join("\n", fn {m, f, a} -> " - #{m}.#{f}/#{a}" end),
      "\n",
      IO.ANSI.reset()
    ])
  end
end
