defmodule MixUnused.Analyzers.Unreachable.Usages.VmstatsDiscoveryTest do
  use ExUnit.Case

  alias MixUnused.Analyzers.Unreachable.Usages.VmstatsDiscovery

  import Mock

  test "it discovers the sink module as defined in the application env" do
    with_mock Application,
      get_env: fn
        :vmstats, :sink -> VMStatsSink
      end do
      usages = VmstatsDiscovery.discover_usages(any: "this is unused")

      assert {VMStatsSink, :collect, 3} in usages
      assert 1 == length(usages)
    end
  end

  test "no usages discovered if no vmstats sink is defined in the application env" do
    with_mock Application,
      get_env: fn
        :vmstats, :sink -> nil
      end do
      usages = VmstatsDiscovery.discover_usages(any: "this is unused")

      assert usages == []
    end
  end
end
