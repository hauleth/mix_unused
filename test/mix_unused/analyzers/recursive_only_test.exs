defmodule MixUnused.Analyzers.RecursiveOnlyTest do
  use ExUnit.Case, async: true

  alias MixUnused.Exports.Meta

  @subject MixUnused.Analyzers.RecursiveOnly

  doctest @subject

  test "no functions" do
    assert %{} == @subject.analyze(%{}, [])
  end

  test "called only recursively" do
    function = {Foo, :a, 1}
    calls = %{Foo => [{function, %{function: {:a, 1}}}]}

    assert %{^function => _} = @subject.analyze(calls, [{function, %Meta{}}])
  end

  test "called by other function within the same module" do
    function = {Foo, :a, 1}
    calls = %{Foo => [
      {function, %{function: {:b, 1}}},
      {function, %{function: {:a, 1}}}
    ]}

    assert %{} == @subject.analyze(calls, [{function, %Meta{}}])
  end
end
