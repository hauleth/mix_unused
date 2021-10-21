defmodule MixUnused.Analyzers.Unused do
  @moduledoc false

  @behaviour MixUnused.Analyze

  @impl true
  def message, do: "is unused"

  @impl true
  def analyze(data, all_functions) do
    calls = Enum.flat_map(data, fn {_key, value} -> value end)

    all_functions
    |> Map.new()
    |> Map.drop(calls)
  end
end
