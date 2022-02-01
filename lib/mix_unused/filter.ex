defmodule MixUnused.Filter do
  @moduledoc false

  import Kernel, except: [match?: 2]

  alias MixUnused.Exports

  @type module_pattern() :: module() | Regex.t() | :_
  @type function_pattern() :: atom() | Regex.t() | :_
  @type arity_pattern() :: arity() | Range.t(arity(), arity()) | :_

  @type pattern() ::
          {module_pattern(), function_pattern(), arity_pattern()}
          | {module_pattern(), function_pattern()}
          | module_pattern()

  @doc """
  Reject values in `exports` that match any pattern in `patterns`.

  ## Examples

  ```
  iex> functions = %{
  ...>   {Foo, :bar, 1} => %{},
  ...>   {Foo, :baz, 1} => %{},
  ...>   {Bar, :foo, 1} => %{}
  ...> }
  iex> patterns = [{Foo, :_, 1}]
  iex> #{inspect(__MODULE__)}.reject_matching(functions, patterns)
  [{{Bar, :foo, 1}, %{}}]
  ```

  The pattern can be just atom which will be then treated as `{mod, :_, :_}`:

  ```
  iex> functions = %{
  ...>   {Foo, :bar, 1} => %{},
  ...>   {Foo, :baz, 1} => %{},
  ...>   {Bar, :foo, 1} => %{}
  ...> }
  iex> patterns = [Foo]
  iex> #{inspect(__MODULE__)}.reject_matching(functions, patterns)
  [{{Bar, :foo, 1}, %{}}]
  ```

  As well it can be 2-ary tuple. Then it will accepr any arity:

  ```
  iex> functions = %{
  ...>   {Foo, :bar, 1} => %{},
  ...>   {Foo, :bar, 2} => %{},
  ...>   {Foo, :baz, 1} => %{}
  ...> }
  iex> patterns = [{Foo, :bar}]
  iex> #{inspect(__MODULE__)}.reject_matching(functions, patterns)
  [{{Foo, :baz, 1}, %{}}]
  ```

  As a pattern for module and function name the reqular expression can be
  passed:

  ```
  iex> functions = %{
  ...>   {Foo, :bar, 1} => %{},
  ...>   {Foo, :baz, 1} => %{}
  ...> }
  iex> patterns = [{Foo, ~r/^ba[rz]$/}]
  iex> #{inspect(__MODULE__)}.reject_matching(functions, patterns)
  []
  ```

  Allow pattern matching module as well:

  ```
  iex> functions = %{
  ...>   {Foo, :bar, 1} => %{},
  ...>   {Foo.Bar, :baz, 1} => %{}
  ...> }
  iex> patterns = [{~r/Foo\..*$/, ~r/^ba[rz]$/}]
  iex> #{inspect(__MODULE__)}.reject_matching(functions, patterns)
  [{{Foo, :bar, 1}, %{}}]
  ```

  For arity you can pass range:

  ```
  iex> functions = %{
  ...>   {Foo, :bar, 1} => %{},
  ...>   {Foo, :bar, 2} => %{},
  ...>   {Foo, :bar, 3} => %{}
  ...> }
  iex> patterns = [{Foo, :bar, 2..3}]
  iex> #{inspect(__MODULE__)}.reject_matching(functions, patterns)
  [{{Foo, :bar, 1}, %{}}]
  ```
  """
  @spec reject_matching(exports :: Exports.t(), patterns :: [pattern()]) ::
          Exports.t()
  def reject_matching(exports, patterns, cb \\ &extract/1) do
    filters =
      Enum.map(patterns, fn
        {_m, _f, _a} = entry -> entry
        {m, f} -> {m, f, :_}
        {m} -> {m, :_, :_}
        m -> {m, :_, :_}
      end)

    Enum.reject(exports, fn data ->
      func = cb.(data)
      Enum.any?(filters, &mfa_match?(&1, func))
    end)
  end

  @spec mfa_match?(mfa(), pattern()) :: boolean()
  defp mfa_match?({pmod, pname, parity}, {fmod, fname, farity}) do
    match?(pmod, fmod) and match?(pname, fname) and arity_match?(parity, farity)
  end

  defp match?(value, value), do: true
  defp match?(:_, _value), do: true

  defp match?(%Regex{} = re, value) when is_atom(value),
    do: inspect(value) =~ re or Atom.to_string(value) =~ re

  defp match?(_, _), do: false

  defp arity_match?(:_, _value), do: true
  defp arity_match?(value, value), do: true
  defp arity_match?(_.._ = range, value), do: value in range
  defp arity_match?(_, _), do: false

  defp extract({func, _}), do: func
end
