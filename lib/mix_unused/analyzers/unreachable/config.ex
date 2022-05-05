defmodule MixUnused.Analyzers.Unreachable.Config do
  @moduledoc false

  alias __MODULE__, as: Config

  @type t :: %Config{
          entrypoints: [module() | mfa()],
          entrypoints_discovery: [module()]
        }

  defstruct entrypoints: [],
            entrypoints_discovery: [
              MixUnused.Analyzers.Unreachable.Entrypoints.AmqpxConsumersDiscovery,
              MixUnused.Analyzers.Unreachable.Entrypoints.HttpMockPalDiscovery
            ]

  @spec cast(Enum.t()) :: Config.t()
  def cast(map) do
    struct!(Config, map)
  end
end
