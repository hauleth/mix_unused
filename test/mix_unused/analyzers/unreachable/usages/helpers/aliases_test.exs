defmodule MixUnused.Analyzers.Unreachable.Usages.Helpers.AliasesTest do
  use ExUnit.Case

  alias MixUnused.Analyzers.Unreachable.Usages.Helpers.Aliases

  test "it is able to resolve simple aliases" do
    aliases =
      Aliases.new(
        quote do
          defmodule A.B.C do
            alias A
            alias A.B
            alias A.B.C
          end
        end
      )

    assert Aliases.resolve(aliases, [:A]) == A
    assert Aliases.resolve(aliases, [:B]) == A.B
    assert Aliases.resolve(aliases, [:C]) == A.B.C
    assert Aliases.resolve(aliases, [:B, :C]) == A.B.C
    assert Aliases.resolve(aliases, [:A, :D]) == A.D
    assert Aliases.resolve(aliases, [:C, :D]) == A.B.C.D
  end

  test "it is able to resolve :as aliases" do
    aliases =
      Aliases.new(
        quote do
          defmodule A.B.C do
            alias A
            alias A.B, as: Foo
            alias A.B.C
          end
        end
      )

    assert Aliases.resolve(aliases, [:A]) == A
    assert Aliases.resolve(aliases, [:B]) == B
    assert Aliases.resolve(aliases, [:Foo]) == A.B
    assert Aliases.resolve(aliases, [:C]) == A.B.C
    assert Aliases.resolve(aliases, [:Foo, :C]) == A.B.C
    assert Aliases.resolve(aliases, [:A, :D]) == A.D
  end

  test "resolving on an empty ast returns the name as is" do
    aliases =
      Aliases.new(
        quote do
        end
      )

    assert Aliases.resolve(aliases, [:A]) == A
    assert Aliases.resolve(aliases, [:B]) == B
    assert Aliases.resolve(aliases, [:C]) == C
    assert Aliases.resolve(aliases, [:B, :C]) == B.C
    assert Aliases.resolve(aliases, [:A, :D]) == A.D
  end

  test "a resolve on an empty atom list returns Elixir" do
    aliases =
      Aliases.new(
        quote do
        end
      )

    assert Aliases.resolve(aliases, []) == Elixir
  end
end
