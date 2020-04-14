defmodule MixUnusedTest do
  use MixUnused.Case, async: false

  describe "umbrella" do
    test "simple file" do
      in_fixture("umbrella", fn ->
        Mix.Project.in_project(:umbrella, ".", fn _ ->
          assert {:ok, diagnostics} = Mix.Task.run("compile")

          assert %Mix.Task.Compiler.Diagnostic{
            compiler_name: "unused",
            severity: :hint,
            position: nil,
            file: "unknown",
            message: "ModuleA.foo/0 is unused"
          } in diagnostics

          assert %Mix.Task.Compiler.Diagnostic{
            compiler_name: "unused",
            severity: :hint,
            position: nil,
            file: "unknown",
            message: "ModuleB.bar/0 is unused"
          } in diagnostics
        end)
      end)
    end
  end

  describe "clean" do
    test "behaviours should not be reported" do
      in_fixture("clean", fn ->
        Mix.Project.in_project(:clean, ".", fn _ ->
          assert {:ok, []} = Mix.Task.run("compile")
        end)
      end)
    end
  end

  describe "unclean" do
    test "ignored function is not reported" do
      in_fixture("unclean", fn ->
        Mix.Project.in_project(:unclean, ".", fn _ ->
          assert {:ok, [msg]} = Mix.Task.run("compile")

          refute match?(%Mix.Task.Compiler.Diagnostic{message: "Foo.bar/0 is unused"}, msg)
        end)
      end)
    end

    test "unused function is reported" do
      in_fixture("unclean", fn ->
        Mix.Project.in_project(:unclean, ".", fn _ ->
          assert {:ok, [msg]} = Mix.Task.run("compile")

          assert %Mix.Task.Compiler.Diagnostic{message: "Foo.foo/0 is unused"} = msg
        end)
      end)
    end
  end
end
