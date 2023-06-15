defmodule Foo do
  def foo do
    "foo"
  end

  def bar do
    Bar.bar()
  end

  def baz do
    Bar.baz()
  end
end
