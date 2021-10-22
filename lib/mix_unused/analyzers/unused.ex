defmodule MixUnused.Analyzers.Unused do
  @moduledoc false

  @behaviour MixUnused.Analyze

  @impl true
  def message, do: "is unused"

  @impl true
  def analyze(data, all_functions) do
    calls = Enum.flat_map(data, fn {_key, value} -> value end)

    all_functions
    |> Enum.reject(fn {_mfa, meta} -> Map.get(meta.doc_meta, :export, false) end)
    |> Map.new()
    |> Map.drop(calls)
  end
end
