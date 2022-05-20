defmodule MixUnused.Analyzers.Unreachable.Usages.Helpers.Source do
  @moduledoc false

  alias MixUnused.Exports
  alias MixUnused.Meta

  @spec read_sources_with_suffix(String.t(), Exports.t()) :: [Macro.t()]
  def read_sources_with_suffix(suffix, exports) do
    suffix
    |> find_sources_by_suffix(exports)
    |> Enum.map(&read_source/1)
  end

  defp find_sources_by_suffix(suffix, exports) do
    exports
    |> Enum.filter(fn {_mfa, %Meta{file: file}} ->
      String.ends_with?(file, suffix)
    end)
    |> Enum.map(fn {_mfa, %Meta{file: file}} -> file end)
    |> Enum.uniq()
  end

  @spec read_module_source(module(), Exports.t()) :: [Macro.t()]
  def read_module_source(module, exports) do
    module
    |> find_module_source(exports)
    |> Enum.map(&read_source/1)
  end

  defp find_module_source(module, exports) do
    case Enum.find(exports, &match?({{^module, _, _}, _meta}, &1)) do
      nil -> []
      {_mfa, %Meta{file: file}} -> [file]
    end
  end

  def read_source(path) do
    path
    |> File.read!()
    |> Code.string_to_quoted!()
  end
end
