defmodule MixUnused.Analyzers.UnusedTest do
  use ExUnit.Case, async: true

  alias MixUnused.Meta

  @subject MixUnused.Analyzers.Unused

  doctest @subject

  test "no functions" do
    assert %{} == @subject.analyze(%{}, %{})
  end

  test "called externally" do
    function = {Foo, :a, 1}
    calls = %{Bar => [{function, %{caller: {:b, 1}}}]}

    assert %{} == @subject.analyze(calls, %{function => %Meta{}})
  end

  test "called internally and externally" do
    function = {Foo, :a, 1}

    calls = %{
      Foo => [{function, %{caller: {:b, 1}}}],
      Bar => [{function, %{caller: {:b, 1}}}]
    }

    assert %{} == @subject.analyze(calls, %{function => %Meta{}})
  end

  test "called only internally" do
    function = {Foo, :a, 1}
    calls = %{Foo => [{function, %{caller: {:b, 1}}}]}

    assert %{} == @subject.analyze(calls, %{function => %Meta{}})
  end

  test "not called at all" do
    function = {Foo, :a, 1}

    assert %{^function => _} = @subject.analyze(%{}, %{function => %Meta{}})
  end

  test "functions with metadata `:export` set to true are ignored" do
    function = {Foo, :a, 1}

    assert %{} ==
             @subject.analyze(
               %{},
               %{function => %Meta{doc_meta: %{export: true}}}
             )
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
               %{function_a => %Meta{}, function_b => %Meta{}}
             )
  end

  test "functions called with default arguments are not reported" do
    function = {Foo, :a, 1}
    functions = %{function => %Meta{doc_meta: %{defaults: 1}}}
    calls = %{Foo => [{{Foo, :a, 0}, %{caller: {:b, 1}}}]}

    assert %{} ==
             @subject.analyze(calls, functions, %{
               usages: [{Foo, :b, 1}]
             })
  end
end
