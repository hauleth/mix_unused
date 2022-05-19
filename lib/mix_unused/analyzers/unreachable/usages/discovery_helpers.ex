defmodule MixUnused.Analyzers.Unreachable.Usages.DiscoveryHelpers do
  @moduledoc false
  
  alias MixUnused.Exports
  alias MixUnused.Meta

  @spec read_sources_with_suffix(String.t(), Exports.t()) :: [Macro.t()]
  def read_sources_with_suffix(suffix, exports) do
    suffix
    |> find_sources(exports)
    |> Enum.map(&read_source/1)
  end

  defp find_sources(suffix, exports) do
    exports
    |> Enum.filter(fn {_mfa, %Meta{file: file}} ->
      String.ends_with?(file, suffix)
    end)
    |> Enum.map(fn {_mfa, %Meta{file: file}} -> file end)
    |> Enum.uniq()
  end

  defp read_source(path) do
    path
    |> File.read!()
    |> Code.string_to_quoted!()
  end
end
