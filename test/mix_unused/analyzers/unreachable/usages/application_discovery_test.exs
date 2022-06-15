defmodule MixUnused.Analyzers.Unreachable.Usages.ApplicationDiscoveryTest do
  use ExUnit.Case

  alias MixUnused.Analyzers.Unreachable.Usages.ApplicationDiscovery

  import Mock

  test "it detects application callbacks" do
    with_mocks [
      {Mix.Project, [], [config: fn -> [app: :my_app] end]},
      {Application, [], [spec: fn :my_app, :mod -> {MyApp, __ENV__} end]}
    ] do
      assert MapSet.new([
               {MyApp, :config_change, 3},
               {MyApp, :prep_stop, 1},
               {MyApp, :start, 2},
               {MyApp, :start_phase, 3},
               {MyApp, :stop, 1}
             ]) === MapSet.new(ApplicationDiscovery.discover_usages([]))
    end
  end
end
