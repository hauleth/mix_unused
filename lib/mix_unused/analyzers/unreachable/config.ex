defmodule MixUnused.Analyzers.Unreachable.Config do
  @moduledoc false

  alias __MODULE__, as: Config

  @type t :: %Config{
          usages: [module() | mfa()],
          usages_discovery: [module()]
        }

  defstruct usages: [],
            usages_discovery: []

  @spec cast(Enum.t()) :: Config.t()
  def cast(map) do
    struct!(Config, map)
  end
end
