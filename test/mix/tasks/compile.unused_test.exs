defmodule Mix.Tasks.Compile.UnusedTest do
  use MixUnused.Case, async: false

  import ExUnit.CaptureIO

  alias MixUnused.Analyzers.{Private, Unused, RecursiveOnly}

  describe "umbrella" do
    test "simple file" do
      in_fixture("umbrella", fn ->
        assert {{:ok, diagnostics}, _} = run(:umbrella, "compile")

        assert find_diagnostics_for(diagnostics, {ModuleA, :foo, 0}, Unused)
        assert find_diagnostics_for(diagnostics, {ModuleB, :bar, 0}, Unused)
      end)
    end

    test "exit if severity is set to error" do
      in_fixture("umbrella", fn ->
        assert {:shutdown, 1} =
                 catch_exit(run(:umbrella, "compile", ~w[--severity error]))
      end)
    end

    test "accepts severity option" do
      in_fixture("umbrella", fn ->
        assert {{:ok, diagnostics}, _} =
                 run(:umbrella, "compile", ~w[--severity info])

        assert %{severity: :information} =
                 find_diagnostics_for(diagnostics, {ModuleA, :foo, 0}, Unused)
      end)
    end

    test "warns on warning severity" do
      in_fixture("umbrella", fn ->
        assert {{:ok, diagnostics}, _} =
                 run(:umbrella, "compile", ~w[--severity warning])

        assert %{severity: :warning} =
                 find_diagnostics_for(diagnostics, {ModuleA, :foo, 0}, Unused)
      end)
    end

    test "exit if severity is warning and `--warnings-as-errors is used`" do
      in_fixture("umbrella", fn ->
        assert {:shutdown, 1}

        catch_exit(
          run(:umbrella, "compile", ~w[--severity warning --warnings-as-errors])
        )
      end)
    end
  end

  describe "clean" do
    test "behaviours should not be reported" do
      in_fixture("clean", fn ->
        assert {{:ok, []}, _} = run(:clean, "compile")
      end)
    end

    test "exit if severity is set to error" do
      in_fixture("clean", fn ->
        assert {{:ok, []}, _} = run(:clean, "compile", ~w[--severity error])
      end)
    end

    test "exit if severity is warning and `--warnings-as-errors is used`" do
      in_fixture("clean", fn ->
        assert {{:ok, []}, _} =
                 run(
                   :clean,
                   "compile",
                   ~w[--severity warning --warnings-as-errors]
                 )
      end)
    end
  end

  describe "unclean" do
    test "ignored function is not reported" do
      in_fixture("unclean", fn ->
        assert {{:ok, diagnostics}, output} = run(:unclean, "compile")

        refute find_diagnostics_for(diagnostics, {Foo, :bar, 0}, Unused)
        refute output =~ "Foo.bar/0 is unused"
      end)
    end

    test "unused function is reported" do
      in_fixture("unclean", fn ->
        assert {{:ok, diagnostics}, output} = run(:unclean, "compile")

        assert output =~ "Foo.foo/0 is unused"
        assert find_diagnostics_for(diagnostics, {Foo, :foo, 0}, Unused)
      end)
    end

    test "unused struct is reported" do
      in_fixture("unclean", fn ->
        assert {{:ok, diagnostics}, output} = run(:unclean, "compile")

        assert output =~ "%Bar{} is unused"
        assert find_diagnostics_for(diagnostics, {Bar, :__struct__, 0}, Unused)
      end)
    end

    test "function that should be private is reported" do
      in_fixture("unclean", fn ->
        assert {{:ok, diagnostics}, output} = run(:unclean, "compile")

        assert output =~ "Foo.baz/0 should be private"
        assert find_diagnostics_for(diagnostics, {Foo, :baz, 0}, Private)
      end)
    end

    test "function that calls itself recursively is not reported" do
      in_fixture("unclean", fn ->
        assert {{:ok, diagnostics}, output} = run(:unclean, "compile")

        refute output =~ "Foo.prod/1 is called only recursively"
        refute find_diagnostics_for(diagnostics, {Foo, :prod, 1}, RecursiveOnly)
      end)
    end

    test "function that is called only recursively is reported" do
      in_fixture("unclean", fn ->
        assert {{:ok, diagnostics}, output} = run(:unclean, "compile")

        assert output =~ "Foo.fact/1 is called only recursively"
        assert find_diagnostics_for(diagnostics, {Foo, :fact, 1}, RecursiveOnly)
      end)
    end

    test "exit if severity is set to error" do
      in_fixture("unclean", fn ->
        assert {:shutdown, 1} =
                 catch_exit(run(:unclean, "compile", ~w[--severity error]))
      end)
    end

    test "accepts severity option" do
      in_fixture("unclean", fn ->
        assert {{:ok, diagnostics}, _} =
                 run(:unclean, "compile", ~w[--severity info])

        assert %{severity: :information} =
                 find_diagnostics_for(diagnostics, {Foo, :foo, 0}, Unused)
      end)
    end

    test "warns on warning severity" do
      in_fixture("unclean", fn ->
        assert {{:ok, diagnostics}, _} =
                 run(:unclean, "compile", ~w[--severity warning])

        assert %{severity: :warning} =
                 find_diagnostics_for(diagnostics, {Foo, :foo, 0}, Unused)
      end)
    end

    test "exit if severity is warning and `--warnings-as-errors is used`" do
      in_fixture("unclean", fn ->
        assert {:shutdown, 1}

        catch_exit(
          run(:unclean, "compile", ~w[--severity warning --warnings-as-errors])
        )
      end)
    end
  end

  describe "two mods" do
    test "when recompiling it inform about unused module" do
      in_fixture("two_mods", fn ->
        assert {{:ok, diagnostics}, output} = run(:two_mods, "compile")
        assert find_diagnostics_for(diagnostics, {Foo, :foo, 0}, Unused)
        refute find_diagnostics_for(diagnostics, {Foo, :bar, 0}, Unused), output

        Mix.Task.clear()

        content =
          File.read!("lib/foo.ex")
          |> String.replace("dummy", "dummer")

        File.write!("lib/foo.ex", content)

        assert {{:ok, diagnostics}, _} = run(:two_mods, "compile")
        assert find_diagnostics_for(diagnostics, {Foo, :foo, 0}, Unused)
        refute find_diagnostics_for(diagnostics, {Foo, :bar, 0}, Unused)
      end)
    end
  end

  describe "cycle" do
     test "unused function is reported" do
       in_fixture("cycle", fn ->
         assert {{:ok, diagnostics}, output} = run(:cycle, "compile")
         refute output =~ "Foo.foo/0 is unused"
         refute output =~ "Bar.bar/0 is unused"
         refute output =~ "Baz.baz/0 is unused"
         refute find_diagnostics_for(diagnostics, {Foo, :foo, 0}, Unused)
         refute find_diagnostics_for(diagnostics, {Bar, :bar, 0}, Unused)
         refute find_diagnostics_for(diagnostics, {Baz, :baz, 0}, Unused)
       end)
     end
   end

  defp run(project, task, args \\ []) do
    Mix.Project.in_project(project, ".", fn _ ->
      captured =
        capture_io(fn ->
          send(self(), {:task, Mix.Task.run(task, args)})
        end)

      send(self(), {:io, captured})
    end)

    assert_received {:task, result}
    assert_received {:io, output}

    {result, output}
  end

  defp find_diagnostics_for(diagnostics, mfa, analyzer) do
    Enum.find(
      diagnostics,
      &(&1.details.mfa == mfa and &1.details.analyzer == analyzer)
    )
  end
end
