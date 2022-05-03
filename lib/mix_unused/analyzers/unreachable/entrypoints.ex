defmodule MixUnused.Analyzers.Unreachable.Entrypoints do
  @moduledoc false

  alias MixUnused.Analyzers.Unreachable.Config

  @callback discover_entrypoints(opts :: any()) :: [mfa()]

  @spec entrypoints(Config.t()) :: [mfa()]
  def entrypoints(%Config{
        entrypoints: static_entrypoints,
        entrypoints_discovery: entrypoints_discovery
      }) do
    static_entrypoints ++ dynamic_entrypoints(entrypoints_discovery)
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
