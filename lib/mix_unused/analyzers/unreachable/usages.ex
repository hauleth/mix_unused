defmodule MixUnused.Analyzers.Unreachable.Usages do
  @moduledoc false

  alias MixUnused.Analyzers.Unreachable.Config
  alias MixUnused.Exports
  alias MixUnused.Debug

  @callback discover_usages(context :: Keyword.t()) :: [mfa()]

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
        discovered_usages(usages_discovery, exports)
      )

    Debug.debug(modules, &debug/1)
  end

  defp declared_usages(hints, exports) do
    Enum.flat_map(hints, fn
      {m, f, a} -> [{m, f, a}]
      m -> for {^m, f, a} <- Map.keys(exports), do: {m, f, a}
    end)
  end

  defp discovered_usages(hints, exports) do
    for module <- hints do
      [
        # the module is itself an used module since it
        #  could call functions created specifically for it
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
      modules |> Enum.map(fn {m, f, a} -> " - #{m}.#{f}/#{a}" end) |> Enum.join("\n"),
      "\n",
      IO.ANSI.reset()
    ])
  end
end
