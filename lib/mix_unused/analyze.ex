defmodule MixUnused.Analyze do
  @moduledoc false

  alias Mix.Task.Compiler.Diagnostic

  alias MixUnused.Config
  alias MixUnused.Exports
  alias MixUnused.Tracer

  @type analyzer :: module() | {module(), any()}

  @callback message() :: String.t()
  @callback analyze(Tracer.data(), Exports.t(), any()) :: Exports.t()

  @spec analyze(
          analyzer() | [analyzer()],
          Tracer.data(),
          Exports.t(),
          Config.t()
        ) ::
          [Diagnostic.t()]
  def analyze(analyzers, data, all_functions, config) when is_list(analyzers),
    do: Enum.flat_map(analyzers, &analyze(&1, data, all_functions, config))

  def analyze(analyzer, data, all_functions, config) when is_atom(analyzer),
    do: analyze({analyzer, nil}, data, all_functions, config)

  def analyze({analyzer, analyzer_config}, data, all_functions, config) do
    message = analyzer.message()

    for {mfa, meta} = desc <-
          analyzer.analyze(data, all_functions, analyzer_config) do
      %Diagnostic{
        compiler_name: "unused",
        message: "#{signature(desc)} #{message}",
        severity: config.severity,
        position: meta.line,
        file: meta.file,
        details: %{
          mfa: mfa,
          signature: meta.signature,
          analyzer: analyzer
        }
      }
    end
  end

  defp signature({{_, :__struct__, 0}, meta}), do: meta.signature
  defp signature({{m, f, a}, _meta}), do: "#{inspect(m)}.#{f}/#{a}"
end
