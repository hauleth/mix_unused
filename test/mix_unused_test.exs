defmodule MixUnusedTest do
  use MixUnused.Case, async: false

  import ExUnit.CaptureIO

  describe "umbrella" do
    test "simple file" do
      in_fixture("umbrella", fn ->
        assert {{:ok, diagnostics}, _} = run(:umbrella, "compile")

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
    end
  end

  describe "clean" do
    test "behaviours should not be reported" do
      in_fixture("clean", fn ->
        assert {{:ok, []}, _} = run(:clean, "compile")
      end)
    end
  end

  describe "unclean" do
    test "ignored function is not reported" do
      in_fixture("unclean", fn ->
        assert {{:ok, [msg]}, output} = run(:unclean, "compile")

        refute match?(%Mix.Task.Compiler.Diagnostic{message: "Foo.bar/0 is unused"}, msg)
        refute output =~ "Foo.bar/0 is unused"
      end)
    end

    test "unused function is reported" do
      in_fixture("unclean", fn ->
        assert {{:ok, [msg]}, output} = run(:unclean, "compile")

        assert %Mix.Task.Compiler.Diagnostic{message: "Foo.foo/0 is unused"} = msg
        assert output =~ "Foo.foo/0 is unused"
      end)
    end
  end

  defp run(project, task) do
    Mix.Project.in_project(project, ".", fn _ ->
      captured =
        capture_io(fn ->
          send(self(), {:task, Mix.Task.run(task)})
        end)

      send(self(), {:io, captured})
    end)

    assert_received {:task, result}
    assert_received {:io, output}

    {result, output}
  end
end
