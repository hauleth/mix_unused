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
        not_called_externally?(mfa, data),
        # Ignore functions with documentation meta `:internal` key set to true
        not Map.get(meta.doc_meta, :internal, false),
        into: %{},
        do: desc
  end

  # Check if function is called only current module.
  defp not_called_externally?({m, _, _} = mfa, data) do
    {current, rest} = Map.pop(data, m, [])

    called?(current, mfa) and
      not Enum.any?(rest, fn {_, calls} ->
        called?(calls, mfa)
      end)
  end

  defp called?(calls, mfa), do: List.keymember?(calls, mfa, 0)
end
