defmodule MixUnusedTest do
  use MixUnused.Case, async: false

  import ExUnit.CaptureIO

  describe "umbrella" do
    test "simple file" do
      in_fixture("umbrella", fn ->
        assert {{:ok, diagnostics}, _} = run(:umbrella, "compile")

        assert has_diagnostics_for?(diagnostics, ModuleA, :foo, 0)
        assert has_diagnostics_for?(diagnostics, ModuleB, :bar, 0)
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
        assert {{:ok, diagnostics}, output} = run(:unclean, "compile")

        refute has_diagnostics_for?(diagnostics, Foo, :bar, 0)
        refute output =~ "Foo.bar/0 is unused"
      end)
    end

    test "unused function is reported" do
      in_fixture("unclean", fn ->
        assert {{:ok, diagnostics}, output} = run(:unclean, "compile")

        assert has_diagnostics_for?(diagnostics, Foo, :foo, 0)
        assert output =~ "Foo.foo/0 is unused"
      end)
    end
  end

  describe "two mods" do
    test "when recompiling it inform about unused module" do
      in_fixture("two_mods", fn ->
        assert {{:ok, diagnostics}, output} = run(:two_mods, "compile")
        assert has_diagnostics_for?(diagnostics, Foo, :foo, 0)
        refute has_diagnostics_for?(diagnostics, Foo, :bar, 0), output

        Mix.Task.clear()

        content =
          File.read!("lib/foo.ex")
          |> String.replace("dummy", "dummer")

        File.write!("lib/foo.ex", content)

        assert {{:ok, diagnostics}, _} = run(:two_mods, "compile")
        assert has_diagnostics_for?(diagnostics, Foo, :foo, 0)
        refute has_diagnostics_for?(diagnostics, Foo, :bar, 0)
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

  defp has_diagnostics_for?(diagnostics, m, f, a) do
    Enum.any?(diagnostics, & &1.message =~ "#{inspect(m)}.#{f}/#{a}")
  end
end
