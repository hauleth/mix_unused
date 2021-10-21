defmodule MixUnused.Exports do
  @moduledoc false

  @type t() :: %{mfa() => metadata()} | [{mfa(), metadata()}]
  @type metadata() :: %{
          signature: String.t(),
          file: String.t(),
          line: non_neg_integer(),
          doc_meta: map()
        }

  @types ~w[function macro]a

  @ignored [
    # It is created automatically by `defstruct` and it is (almost?) never used
    # directly. Instead we will look for expansions in form of `%module{}`
    {:__struct__, 1}
  ]

  def application(name) do
    _ = Application.load(name)

    name
    |> Application.spec(:modules)
    |> Enum.flat_map(&fetch/1)
    |> Map.new()
  end

  @spec fetch(module()) :: [{mfa(), metadata()}]
  def fetch(module) do
    # Check exported functions without loading modules as this could cause
    # unexpected behaviours in case of `on_load` callbacks
    with path when is_list(path) <- :code.which(module),
         {:ok, {^module, data}} <-
           :beam_lib.chunks(path, [:attributes, :compile_info]),
         {_hidden?, _meta, docs} <- fetch_docs(to_string(path)) do
      callbacks =
        data[:attributes] |> Keyword.get(:behaviour, []) |> callbacks()

      source =
        data[:compile_info] |> Keyword.get(:source, "nofile") |> to_string()

      for {{type, name, arity}, anno, [sig | _], _doc, meta} <- docs,
          type in @types,
          {name, arity} not in @ignored,
          {name, arity} not in callbacks do
        line = :erl_anno.line(anno)

        {{module, name, arity},
         %{signature: sig, file: source, line: line, doc_meta: meta}}
      end
    else
      _ -> []
    end
  end

  defp callbacks(behaviours) do
    # We need to load behaviours as there is no other way to get list of
    # callbacks than to call `behaviour_info/1`
    Enum.flat_map(behaviours, fn mod ->
      case fetch_docs(mod) do
        {_hidden, _meta, docs} ->
          Enum.flat_map(docs, fn
            {{:callback, f, a}, _anno, _sig, _doc, _meta} -> [{f, a}]
            _ -> []
          end)

        _ ->
          mod.behaviour_info(:callbacks)
      end
    end)
  end

  defp fetch_docs(mod) do
    case Code.fetch_docs(mod) do
      {:docs_v1, _anno, _lang, _format, mod_doc, meta, docs} ->
        {mod_doc == :hidden, meta, docs}

      _ ->
        []
    end
  end
end
