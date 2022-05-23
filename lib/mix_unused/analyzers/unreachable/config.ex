defmodule MixUnused.Analyzers.Unreachable.Config do
  @moduledoc false

  alias __MODULE__, as: Config

  @type t :: %Config{
          usages: [module() | mfa()],
          usages_discovery: [module()],
          report_transitively_unused: boolean()
        }

  defstruct usages: [],
            usages_discovery: [],
            report_transitively_unused: false

  @spec cast(Enum.t()) :: Config.t()
  def cast(map) do
    struct!(Config, map)
  end
end
