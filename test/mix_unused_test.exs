defmodule MixUnusedTest do
  use ExUnit.Case

  alias Mix.Tasks.Unused, as: Subject

  doctest Subject

  test "greets the world" do
    assert Subject.run(["--quiet"]) == :ok
  end
end
