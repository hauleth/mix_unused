defmodule MixUnused.Analyzers.Unreachable.Config do
  @moduledoc false

  alias __MODULE__, as: Config

  @type t :: %Config{
          usages: [module() | mfa()],
          usages_discovery: [module()]
        }

  defstruct usages: [],
            usages_discovery: [
              MixUnused.Analyzers.Unreachable.Usages.AmqpxConsumersDiscovery,
              MixUnused.Analyzers.Unreachable.Usages.HttpMockPalDiscovery
            ]

  @spec cast(Enum.t()) :: Config.t()
  def cast(map) do
    struct!(Config, map)
  end
end
