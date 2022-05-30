defmodule MixUnused.Filter do
  @moduledoc false

  import Kernel, except: [match?: 2]

  alias MixUnused.Exports
  alias MixUnused.Meta

  @type module_pattern() :: module() | Regex.t() | :_
  @type function_pattern() :: atom() | Regex.t() | :_
  @type arity_pattern() :: arity() | Range.t(arity(), arity()) | :_

  @type mfa_pattern() ::
          {module_pattern(), function_pattern(), arity_pattern()}
          | {module_pattern(), function_pattern()}
          | module_pattern()

  @type predicate() :: ({module(), atom(), arity()} -> boolean())

  @type pattern() :: predicate() | mfa_pattern()

  # Reject values in `exports` that match any pattern in `patterns`.
  @doc false
  @spec reject_matching(exports :: Exports.t(), patterns :: [pattern()]) ::
          Exports.t()
  def reject_matching(exports, patterns) do
    Map.reject(exports, matcher(patterns))
  end

  @spec filter_matching(exports :: Exports.t(), patterns :: [pattern()]) ::
          Exports.t()
  def filter_matching(exports, patterns) do
    Map.filter(exports, matcher(patterns))
  end

  @spec matcher(patterns :: [pattern()]) :: ({mfa(), Meta.t()} -> boolean())
  defp matcher(patterns) do
    filters = normalize_filter_patterns(patterns)

    fn {mfa, meta} -> Enum.any?(filters, &mfa_match?(&1, mfa, meta)) end
  end

  @spec normalize_filter_patterns(patterns :: [pattern()]) :: [pattern()]
  defp normalize_filter_patterns(patterns) do
    Enum.map(patterns, fn
      {_m, _f, _a} = entry -> entry
      {m, f} -> {m, f, :_}
      {m} -> {m, :_, :_}
      m when is_atom(m) -> {m, :_, :_}
      %Regex{} = m -> {m, :_, :_}
      cb when is_function(cb) -> cb
    end)
  end

  @spec mfa_match?(pattern(), mfa(), Meta.t()) :: boolean()
  defp mfa_match?({pmod, pname, parity}, {fmod, fname, farity}, _meta) do
    match?(pmod, fmod) and match?(pname, fname) and arity_match?(parity, farity)
  end

  defp mfa_match?(cb, mfa, _meta) when is_function(cb, 1), do: cb.(mfa)
  defp mfa_match?(cb, mfa, meta) when is_function(cb, 2), do: cb.(mfa, meta)

  defp match?(value, value), do: true
  defp match?(:_, _value), do: true

  defp match?(%Regex{} = re, value) when is_atom(value),
    do: inspect(value) =~ re or Atom.to_string(value) =~ re

  defp match?(_, _), do: false

  defp arity_match?(:_, _value), do: true
  defp arity_match?(value, value), do: true
  defp arity_match?(_.._ = range, value), do: value in range
  defp arity_match?(_, _), do: false
end
