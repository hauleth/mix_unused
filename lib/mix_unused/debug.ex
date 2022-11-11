defmodule MixUnused.Debug do
  @moduledoc false

  @spec debug(v, (v -> term)) :: v when v: var
  def debug(value, fun) do
    if debug?(), do: fun.(value)
    value
  end

  defp debug?, do: System.get_env("MIX_UNUSED_DEBUG") == "true"
end
