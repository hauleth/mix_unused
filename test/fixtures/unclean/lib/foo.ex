defmodule Foo do
  def foo do
    prod(4)
    baz()
  end

  def bar, do: :error

  def baz, do: :ok

  def fact(0), do: 1
  def fact(n) when n > 0, do: fact(n - 1) * n

  def prod(1), do: 1
  def prod(n) when n > 1, do: prod(n - 1) * n
end
