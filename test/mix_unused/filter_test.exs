defmodule MixUnused.FilterTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias MixUnused.Meta

  @subject MixUnused.Filter

  doctest @subject

  def func_name do
    gen(
      all str <- string([?a..?z, ?A..?Z, ?0..?9, ?_], max_length: 254),
          last <- string([??, ?!], max_length: 1),
          first <- string([?a..?z]),
          do: String.to_atom(first <> str <> last)
    )
  end

  def mfa do
    gen(
      all module <- atom(:alias),
          function <- func_name(),
          arity <- integer(0..255),
          module != :_,
          function != :_,
          do: {module, function, arity}
    )
  end

  def mfa_pattern({m, f, a}) do
    gen(
      all module <- frequency([{1, constant(:_)}, {9, constant(m)}]),
          function <- frequency([{1, constant(:_)}, {9, constant(f)}]),
          arity <- frequency([{1, constant(:_)}, {9, constant(a)}]),
          do: {module, function, arity}
    )
  end

  test "exact pattern" do
    functions = %{
      {Foo, :bar, 1} => %Meta{},
      {Bar, :baz, 2} => %Meta{}
    }

    patterns = [{Foo, :bar, 1}]

    assert @subject.reject_matching(functions, patterns) == %{
             {Bar, :baz, 2} => %Meta{}
           }
  end

  @tag :slow
  property "empty pattern list works as passthrough" do
    check all functions <- map_of(mfa(), constant(%Meta{})) do
      assert functions == @subject.reject_matching(functions, [])
    end
  end

  property "simple patterns" do
    check all mfa <- mfa(),
              pattern <- mfa_pattern(mfa) do
      functions = %{mfa => %Meta{}}

      assert %{} == @subject.reject_matching(functions, [pattern])
    end
  end

  property "reduced patterns" do
    check all mfa <- mfa(),
              {m, f, _} = mfa_pattern <- mfa_pattern(mfa),
              pattern <-
                one_of([
                  constant(mfa_pattern),
                  tuple({m, f}),
                  tuple({m}),
                  constant(m)
                ]) do
      functions = %{mfa => %Meta{}}

      assert %{} == @subject.reject_matching(functions, [pattern])
    end
  end

  describe "regular expression" do
    test "can be used for function name" do
      functions = %{
        {Foo, :bar, 1} => %Meta{},
        {Foo, :baz, 1} => %Meta{}
      }

      patterns = [{Foo, ~r/^ba[rz]$/}]
      assert @subject.reject_matching(functions, patterns) == %{}
    end

    test "can be used for module name" do
      functions = %{
        {Foo, :bar, 1} => %Meta{},
        {Foo, :baz, 1} => %Meta{}
      }

      patterns = [{Foo, ~r/^ba[rz]$/}]
      assert @subject.reject_matching(functions, patterns) == %{}
    end

    test "raw regex matches module name" do
      functions = %{
        {Foo, :bar, 1} => %Meta{},
        {Boo, :bar, 1} => %Meta{}
      }

      patterns = [~r/.oo/]
      assert @subject.reject_matching(functions, patterns) == %{}

      functions = %{
        {Foo, :far, 1} => %Meta{},
        {Boo, :bar, 1} => %Meta{}
      }

      patterns = [~r/.ar/]
      refute @subject.reject_matching(functions, patterns) == %{}
    end
  end

  describe "range" do
    test "arity can be checked against range" do
      functions = %{
        {Foo, :bar, 1} => %Meta{},
        {Foo, :bar, 2} => %Meta{},
        {Foo, :bar, 3} => %Meta{}
      }

      patterns = [{Foo, :bar, 2..3}]

      assert @subject.reject_matching(functions, patterns) == %{
               {Foo, :bar, 1} => %Meta{}
             }
    end
  end

  describe "predicate function" do
    test "simple predicate" do
      functions = %{
        {Foo, :bar, 1} => %Meta{},
        {Foo, :bar, 2} => %Meta{},
        {Foo, :bar, 3} => %Meta{}
      }

      patterns = [&match?({Foo, :bar, 2}, &1)]

      assert @subject.reject_matching(functions, patterns) == %{
               {Foo, :bar, 1} => %Meta{},
               {Foo, :bar, 3} => %Meta{}
             }
    end

    test "metadata predicate" do
      functions = %{
        {Foo, :bar, 1} => %Meta{},
        {Foo, :bar, 2} => %Meta{file: "ignore.ex"},
        {Foo, :bar, 3} => %Meta{file: "keep.ex"}
      }

      predicate = fn _, meta ->
        meta.file == "ignore.ex"
      end

      patterns = [predicate]

      assert @subject.reject_matching(functions, patterns) == %{
               {Foo, :bar, 1} => %Meta{},
               {Foo, :bar, 3} => %Meta{file: "keep.ex"}
             }
    end
  end
end
