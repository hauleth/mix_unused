defmodule MixUnused.Analyzers.Unused do
  @moduledoc false

  @behaviour MixUnused.Analyze

  @impl true
  def message, do: "is unused"

  @impl true
  def analyze(data, all_functions) do
    calls =
      for {_key, calls} <- data,
          {mfa, _env} <- calls,
          do: mfa

    all_functions
    |> Enum.reject(fn {_mfa, meta} -> Map.get(meta.doc_meta, :export, false) end)
    |> Map.new()
    |> Map.drop(calls)
  end
end
