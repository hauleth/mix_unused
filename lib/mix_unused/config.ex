defmodule MixUnused.Config do
  @moduledoc false

  defstruct checks: [
              MixUnused.Analyzers.Private,
              MixUnused.Analyzers.Unused,
              MixUnused.Analyzers.RecursiveOnly
            ],
            ignore: [],
            severity: :hint,
            warnings_as_errors: false

  @options [
    severity: :string,
    warnings_as_errors: :boolean
  ]

  def build(argv, config) do
    {opts, _rest, _other} = OptionParser.parse(argv, strict: @options)

    %__MODULE__{}
    |> extract_config(config)
    |> extract_opts(opts)
  end

  defp extract_config(%__MODULE__{} = config, mix_config) do
    config
    |> maybe_set(:checks, mix_config[:checks])
    |> maybe_set(:ignore, mix_config[:ignore])
    |> maybe_set(:severity, mix_config[:severity])
    |> maybe_set(:warnings_as_errors, mix_config[:warnings_as_errors])
  end

  defp extract_opts(%__MODULE__{} = config, opts) do
    config
    |> maybe_set(:severity, opts[:severity], &severity/1)
    |> maybe_set(:warnings_as_errors, opts[:warnings_as_errors])
  end

  defp maybe_set(map, key, value, transform \\ fn x -> x end)

  defp maybe_set(map, _key, nil, _transform), do: map

  defp maybe_set(map, key, value, transform),
    do: Map.put(map, key, transform.(value))

  defp severity("hint"), do: :hint
  defp severity("info"), do: :information
  defp severity("information"), do: :information
  defp severity("warn"), do: :warning
  defp severity("warning"), do: :warning
  defp severity("error"), do: :error
end
