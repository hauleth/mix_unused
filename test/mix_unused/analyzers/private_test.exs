defmodule MixUnused.Analyzers.PrivateTest do
  use ExUnit.Case, async: true

  @subject MixUnused.Analyzers.Private

  doctest @subject

  describe "simple" do
    test "no functions" do
      assert %{} == @subject.analyze(%{}, [])
    end

    test "called externally" do
      function = {Foo, :a, 1}
      calls = %{Bar => [function]}

      assert %{} == @subject.analyze(calls, [{function, %{}}])
    end

    test "called internally and externally" do
      function = {Foo, :a, 1}

      calls = %{
        Foo => [function],
        Bar => [function]
      }

      assert %{} == @subject.analyze(calls, [{function, %{}}])
    end

    test "called only internally" do
      function = {Foo, :a, 1}
      calls = %{Foo => [function]}

      assert %{^function => _} = @subject.analyze(calls, [{function, %{}}])
    end
  end
end
