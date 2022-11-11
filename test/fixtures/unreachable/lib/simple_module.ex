defmodule SimpleModule do
  use SimpleMacro

  # use function at compile-time
  @answer Constants.answer()

  def use_foo(struct), do: SimpleStruct.foo(struct) == @answer

  def used_from_unused, do: f()

  def public_unused, do: f()

  def public_used_by_unused_private, do: f()

  defp private_unused do
    public_used_by_unused_private()
  end
end
