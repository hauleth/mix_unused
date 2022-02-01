defmodule MixUnused.Analyzers.RecursiveOnly do
  @moduledoc false

  @behaviour MixUnused.Analyze

  @impl true
  def message, do: "is called only recursively"

  @impl true
  def analyze(data, all_functions) do
    non_rec_calls =
      for {mod, calls} <- data,
          {{m, f, a} = mfa, %{caller: {call_f, call_a}}} <- calls,
          m != mod or f != call_f or a != call_a,
          do: mfa

    recursive_calls =
      for {module, calls} <- data,
          {{^module, f, a} = mfa, %{caller: {f, a}}} <- calls,
          mfa not in non_rec_calls,
          do: mfa

    all_functions
    |> Map.new()
    |> Map.take(recursive_calls)
  end
end
