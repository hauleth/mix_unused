defmodule MixUnused.Analyzers.Unreachable.Usages.Helpers.BehavioursTest do
  use ExUnit.Case

  alias MixUnused.Analyzers.Unreachable.Usages.Helpers.Behaviours

  test "get module callbacks" do
    assert [{MixUnused.Analyzers.Unreachable.Usages, :discover_usages, 1}] =
             Behaviours.callbacks(MixUnused.Analyzers.Unreachable.Usages)
  end
end
