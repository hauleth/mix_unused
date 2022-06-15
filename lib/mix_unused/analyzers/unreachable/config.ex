defmodule MixUnused.Analyzers.Unreachable.Config do
  @moduledoc """
  Configuration specific to the [Unreachable](`MixUnused.Analyzers.Unreachable`) analyzer.
  """
  alias MixUnused.Filter

  @type t :: %__MODULE__{
          usages: [Filter.pattern()],
          usages_discovery: [module()],
          report_transitively_unused: boolean()
        }

  defstruct usages: [],
            usages_discovery: [],
            report_transitively_unused: false

  @spec cast(Enum.t()) :: t()
  def cast(map) do
    struct!(__MODULE__, map)
  end
end
