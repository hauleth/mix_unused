defmodule MixUnused.Analyzers.Private do
  @moduledoc false

  @behaviour MixUnused.Analyze

  @impl true
  def message, do: "should be private (is not used outside defining module)"

  @impl true
  def analyze(data, all_functions) do
    data = Map.new(data)

    for {{_, f, _} = mfa, meta} = desc <- all_functions,
        # Ignore `__.*__` as these are often meant to be called only internally
        not (to_string(f) =~ ~r/__.*__/),
        not called_externally?(mfa, data),
        not Map.get(meta, :internal, false),
        into: %{},
        do: desc
  end

  defp called_externally?({m, _, _} = mfa, data) do
    data
    |> Map.delete(m)
    |> Enum.any?(fn {_, calls} -> mfa in calls end)
  end
end
