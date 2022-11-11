defmodule UnusedStruct do
  defstruct [:bar]

  def unused(), do: SimpleModule.used_from_unused()
end
