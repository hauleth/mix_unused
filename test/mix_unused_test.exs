defmodule MixUnusedTest do
  use ExUnit.Case
  doctest MixUnused

  test "greets the world" do
    assert MixUnused.hello() == :world
  end
end
