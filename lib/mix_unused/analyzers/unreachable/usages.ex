defmodule MixUnused.Analyzers.Unreachable.Usages do
  @moduledoc """
  Provides the starting points for the [Unreachable](`MixUnused.Analyzers.Unreachable`) analyzer.
  """

  alias MixUnused.Analyzers.Calls
  alias MixUnused.Analyzers.Unreachable.Config
  alias MixUnused.Debug
  alias MixUnused.Exports
  alias MixUnused.Filter

  defmodule Context do
    @moduledoc false

    @type t :: %__MODULE__{
            calls: Calls.t(),
            exports: Exports.t()
          }
    defstruct [:calls, :exports]
  end

  @doc """
  Called during the analysis to search potential used functions.

  It receives the map of all the exported functions and returns
  the list of found functions.
  """
  @callback discover_usages(Context.t()) :: [mfa()]

  @default_discoveries [
    MixUnused.Analyzers.Unreachable.Usages.AbsintheDiscovery,
    MixUnused.Analyzers.Unreachable.Usages.AmqpxConsumersDiscovery,
    MixUnused.Analyzers.Unreachable.Usages.ExqDiscovery,
    MixUnused.Analyzers.Unreachable.Usages.HttpMockPalDiscovery,
    MixUnused.Analyzers.Unreachable.Usages.PhoenixDiscovery,
    MixUnused.Analyzers.Unreachable.Usages.SupervisorDiscovery,
    MixUnused.Analyzers.Unreachable.Usages.VmstatsDiscovery
  ]

  @spec usages(Config.t(), Context.t()) :: [mfa()]
  def usages(
        %Config{
          usages: usages,
          usages_discovery: usages_discovery
        },
        context
      ) do
    modules =
      Enum.concat(
        declared_usages(usages, context),
        discovered_usages(usages_discovery ++ @default_discoveries, context)
      )

    Debug.debug(modules, &debug/1)
  end

  @spec declared_usages([Filter.pattern()], Context.t()) :: [mfa()]
  defp declared_usages(patterns, %Context{exports: exports}) do
    Filter.filter_matching(exports, patterns) |> Map.keys()
  end

  @spec discovered_usages([module()], Context.t()) :: [mfa()]
  defp discovered_usages(modules, context) do
    for module <- modules do
      [
        # the module is itself an used module since it
        # could call functions created specifically for it
        {module, :discover_usages, 1}
        | apply(module, :discover_usages, [context])
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
