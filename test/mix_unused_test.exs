defmodule MixUnusedTest do
  use MixUnused.Case

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
end
