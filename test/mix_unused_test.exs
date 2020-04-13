defmodule MixUnusedTest do
  use MixUnused.Case

  test "simple file" do
    in_fixture("umbrella", fn ->
      Mix.Project.in_project(:umbrella, ".", fn _ ->
        assert nil = Mix.Task.run("compile")
      end)
    end)
  end
end
