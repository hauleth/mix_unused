defmodule MixUnused.Analyze do
  @moduledoc false

  alias Mix.Task.Compiler.Diagnostic

  alias MixUnused.Exports

  @type data :: %{module() => [mfa()]}

  @callback message() :: iodata()
  @callback analyze(data(), Exports.t()) :: Exports.t()

  @spec analyze(module() | [module()], data(), Exports.t(), map()) ::
          Diagnostic.t()
  def analyze(analyzers, data, all_functions, config) when is_list(analyzers),
    do: Enum.flat_map(analyzers, &analyze(&1, data, all_functions, config))

  def analyze(analyzer, data, all_functions, config) when is_atom(analyzer) do
    message = analyzer.message()

    for {mfa, meta} = desc <- analyzer.analyze(data, all_functions) do
      %Diagnostic{
        compiler_name: "unused",
        message: message(desc, message),
        severity: config.severity,
        position: meta[:line],
        file: meta[:file] || "nofile",
        details: %{
          mfa: mfa,
          signature: meta[:signature]
        }
      }
    end
  end

  defp message({{_, :__struct__, 0}, meta}, message) do
    "#{meta.signature} #{message}"
  end

  defp message({{m, f, a}, _meta}, message) do
    "#{inspect(m)}.#{f}/#{a} #{message}"
  end
end
