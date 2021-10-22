defmodule MixUnused.Analyzers.UnusedTest do
  use ExUnit.Case, async: true

  alias MixUnused.Exports.Meta

  @subject MixUnused.Analyzers.Unused

  doctest @subject

  test "no functions" do
    assert %{} == @subject.analyze(%{}, [])
  end

  test "called externally" do
    function = {Foo, :a, 1}
    calls = %{Bar => [function]}

    assert %{} == @subject.analyze(calls, [{function, %Meta{}}])
  end

  test "called internally and externally" do
    function = {Foo, :a, 1}

    calls = %{
      Foo => [function],
      Bar => [function]
    }

    assert %{} == @subject.analyze(calls, [{function, %Meta{}}])
  end

  test "called only internally" do
    function = {Foo, :a, 1}
    calls = %{Foo => [function]}

    assert %{} == @subject.analyze(calls, [{function, %Meta{}}])
  end

  test "not called at all" do
    function = {Foo, :a, 1}

    assert %{^function => _} = @subject.analyze(%{}, [{function, %Meta{}}])
  end

  test "functions with metadata `:export` set to true are ignored" do
    function = {Foo, :a, 1}

    assert %{} ==
             @subject.analyze(%{}, [
               {function, %Meta{doc_meta: %{export: true}}}
             ])
  end
end
