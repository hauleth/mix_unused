defmodule MixUnused.Analyzers.Unreachable.Usages do
  @moduledoc false

  alias MixUnused.Analyzers.Unreachable.Config
  alias MixUnused.Exports

  @callback discover_usages(context :: map()) :: [mfa()]

  @spec usages(Config.t(), Exports.t()) :: [mfa()]
  def usages(
        %Config{
          usages: usages,
          usages_discovery: usages_discovery
        },
        functions
      ) do
    declared_usages(usages, functions) ++
      discovered_usages(usages_discovery)
  end

  defp declared_usages(hints, functions) do
    Enum.flat_map(hints, fn
      {m, f, a} -> [{m, f, a}]
      m -> for {^m, f, a} <- Map.keys(functions), do: {m, f, a}
    end)
  end

  defp discovered_usages(hints) do
    for module <- hints do
      [
        # the module is itself an used module since it
        #  could call functions created specifically for it
        {module, :discover_usages, 1}
        | apply(module, :discover_usages, [%{}])
      ]
    end
    |> List.flatten()
  end
end
