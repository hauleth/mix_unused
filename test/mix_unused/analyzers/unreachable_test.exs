defmodule MixUnused.Analyzers.UnreachableTest do
  use ExUnit.Case, async: true

  alias MixUnused.Meta

  @subject MixUnused.Analyzers.Unreachable

  doctest @subject

  test "no functions" do
    assert %{} == @subject.analyze(%{}, %{}, %{})
  end

  test "called externally but undeclared" do
    function = {Foo, :a, 1}
    calls = %{Bar => [{function, %{caller: {:b, 1}}}]}

    assert %{} ==
             @subject.analyze(calls, %{function => %Meta{}}, %{
               entrypoints: [{Bar, :b, 1}]
             })
  end

  test "called internally and externally" do
    function_a = {Foo, :a, 1}
    function_b = {Foo, :b, 1}

    functions = %{
      function_a => %Meta{},
      function_b => %Meta{}
    }

    calls = %{
      Foo => [{function_a, %{caller: {:b, 1}}}],
      Bar => [{function_b, %{caller: {:c, 1}}}]
    }

    assert %{} ==
             @subject.analyze(calls, functions, %{
               entrypoints: [{Bar, :c, 1}]
             })
  end

  test "called only internally" do
    function = {Foo, :a, 1}
    calls = %{Foo => [{function, %{caller: {:b, 1}}}]}

    assert %{} ==
             @subject.analyze(calls, %{function => %Meta{}}, %{
               entrypoints: [{Foo, :b, 1}]
             })
  end

  test "not called at all" do
    function = {Foo, :a, 1}

    assert %{^function => _} =
             @subject.analyze(%{}, %{function => %Meta{}}, %{
               entrypoints: [{Foo, :b, 1}]
             })
  end

  test "transitive functions are reported" do
    function_a = {Foo, :a, 1}
    function_b = {Foo, :b, 1}

    calls = %{
      Foo => [{function_b, %{caller: {:a, 1}}}]
    }

    assert %{
             ^function_a => _,
             ^function_b => _
           } =
             @subject.analyze(
               calls,
               %{function_a => %Meta{}, function_b => %Meta{}},
               %{}
             )
  end

  test "functions with default arguments are honored" do
    function = {Foo, :a, 1}
    functions = %{function => %Meta{doc_meta: %{defaults: 1}}}
    calls = %{Foo => [{{Foo, :a, 0}, %{caller: {:b, 1}}}]}

    assert %{} ==
             @subject.analyze(calls, functions, %{
               entrypoints: [{Foo, :b, 1}]
             })
  end

  test "functions evaluated at compile-time are not reported" do
    function_a = {Foo, :a, 1}
    function_b = {Foo, :b, 1}

    calls = %{
      Foo => [{function_b, %{caller: nil}}]
    }

    assert %{^function_a => _} =
             @subject.analyze(
               calls,
               %{function_a => %Meta{}, function_b => %Meta{}},
               %{}
             )
  end
end
