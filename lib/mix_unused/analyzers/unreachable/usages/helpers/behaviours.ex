defmodule MixUnused.Analyzers.Unreachable.Usages.Helpers.Behaviours do
  @moduledoc false

  @spec callbacks(module()) :: [mfa()]
  def callbacks(module) do
    {:docs_v1, _anno, _lang, _format, _mod_doc, _meta, docs} =
      Code.fetch_docs(module)

    for {{:callback, f, a}, _anno, _sig, _doc, _meta} <- docs do
      {module, f, a}
    end
  end
end
