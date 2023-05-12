defmodule Bar do
  def foo do
    Baz.foo()
  end

  def bar do
    "bar"
  end

  def baz do
    Baz.baz()
  end
end
