defmodule SimpleModule do

  use SimpleMacro

  # use function at compile-time
  @answer Constants.answer()

  def use_foo(struct), do: SimpleStruct.foo(struct) == @answer

  def used_from_unused, do: f()
end
