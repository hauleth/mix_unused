defmodule MixUnused.Utils do
  @moduledoc false

  import Kernel, except: [match?: 2]

  def mfa_match?({pmod, pname, parity}, {fmod, fname, farity}) do
    match?(pmod, fmod) and match?(pname, fname) and match?(parity, farity)
  end

  def match?(value, value), do: true
  def match?(:_, _value), do: true
  def match?(_.._ = range, value) when is_integer(value), do: value in range
  def match?(%Regex{} = re, value) when is_atom(value), do: inspect(value) =~ re or Atom.to_string(value) =~ re
  def match?(_, _), do: false
end
