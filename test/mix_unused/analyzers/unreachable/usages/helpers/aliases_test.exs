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

    assert Aliases.resolve(aliases, alias_node([:A])) == {:ok, A}
    assert Aliases.resolve(aliases, alias_node([:B])) == {:ok, A.B}
    assert Aliases.resolve(aliases, alias_node([:C])) == {:ok, A.B.C}
    assert Aliases.resolve(aliases, alias_node([:B, :C])) == {:ok, A.B.C}
    assert Aliases.resolve(aliases, alias_node([:A, :D])) == {:ok, A.D}
    assert Aliases.resolve(aliases, alias_node([:C, :D])) == {:ok, A.B.C.D}
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

    assert Aliases.resolve(aliases, alias_node([:A])) == {:ok, A}
    assert Aliases.resolve(aliases, alias_node([:B])) == {:ok, B}
    assert Aliases.resolve(aliases, alias_node([:Foo])) == {:ok, A.B}
    assert Aliases.resolve(aliases, alias_node([:C])) == {:ok, A.B.C}
    assert Aliases.resolve(aliases, alias_node([:Foo, :C])) == {:ok, A.B.C}
    assert Aliases.resolve(aliases, alias_node([:A, :D])) == {:ok, A.D}
  end

  test "resolving on an empty ast returns the name as is" do
    aliases = Aliases.new(nil)

    assert Aliases.resolve(aliases, alias_node([:A])) == {:ok, A}
    assert Aliases.resolve(aliases, alias_node([:B])) == {:ok, B}
    assert Aliases.resolve(aliases, alias_node([:C])) == {:ok, C}
    assert Aliases.resolve(aliases, alias_node([:B, :C])) == {:ok, B.C}
    assert Aliases.resolve(aliases, alias_node([:A, :D])) == {:ok, A.D}
  end

  test "a resolve on an empty atom list returns Elixir" do
    aliases = Aliases.new(nil)
    assert Aliases.resolve(aliases, alias_node([])) == {:ok, Elixir}
  end

  test "a resolve on an unsupported ast returns error" do
    aliases = Aliases.new(nil)
    assert Aliases.resolve(aliases, nil) == :error
  end

  test "it resolves unique aliases from nested modules" do
    aliases =
      Aliases.new(
        quote do
          defmodule A.B.C do
            alias A.B

            defmodule D do
              alias A.B.C
              # ignored since already defined at top level
              alias B2, as: B
            end
          end
        end
      )

    assert Aliases.resolve(aliases, alias_node([:B])) == {:ok, A.B}
    assert Aliases.resolve(aliases, alias_node([:C])) == {:ok, A.B.C}
  end

  test "it resolves __MODULE__ to the top level module" do
    aliases =
      Aliases.new(
        quote do
          defmodule A.B.C do
            defmodule D do
            end
          end
        end
      )

    assert Aliases.resolve(aliases, __module__node()) == {:ok, A.B.C}
  end

  defp alias_node(atoms), do: {:__aliases__, [], atoms}
  defp __module__node, do: {:__MODULE__, [], Elixir}
end
