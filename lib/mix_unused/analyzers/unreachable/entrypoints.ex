defmodule MixUnused.Analyzers.Unreachable.Entrypoints do
  @moduledoc false

  alias MixUnused.Analyzers.Unreachable.Config
  alias MixUnused.Exports

  @callback discover_entrypoints(context :: map()) :: [mfa()]

  @spec entrypoints(Config.t(), Exports.t()) :: [mfa()]
  def entrypoints(
        %Config{
          entrypoints: entrypoints,
          entrypoints_discovery: entrypoints_discovery
        },
        functions
      ) do
    static_entrypoints(entrypoints, functions) ++
      dynamic_entrypoints(entrypoints_discovery)
  end

  defp static_entrypoints(entrypoints, functions) do
    Enum.flat_map(entrypoints, fn
      {m, f, a} -> [{m, f, a}]
      m -> for {^m, f, a} <- Map.keys(functions), do: {m, f, a}
    end)
  end

  defp dynamic_entrypoints(entrypoints_discovery) do
    for module <- entrypoints_discovery do
      [
        # the entrypoint module is itself an entrypoint since
        # it could call functions created specifically for it
        {module, :discover_entrypoints, 1}
        | apply(module, :discover_entrypoints, [%{}])
      ]
    end
    |> List.flatten()
  end
end
