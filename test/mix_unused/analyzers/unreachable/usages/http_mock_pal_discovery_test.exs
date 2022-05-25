defmodule MixUnused.Analyzers.Unreachable.Usages.HttpMockPalDiscoveryTest do
  use ExUnit.Case

  alias MixUnused.Analyzers.Unreachable.Usages.HttpMockPalDiscovery

  import Mock

  test "it discovers the mock modules and respective :call/2 as defined in the application env" do
    with_mock Application,
      get_env: fn
        :http_mock_pal, :routers, [] ->
          [
            {MyFirstMock, port: 5000},
            {MySecondMock, port: 8000}
          ]
      end do
      usages = HttpMockPalDiscovery.discover_usages(any: "this is unused")

      assert {MyFirstMock, :call, 2} in usages
      assert {MySecondMock, :call, 2} in usages
      assert 2 == length(usages)
    end
  end

  test "no usages discovered if no mock modules are defined in the application env" do
    with_mock Application,
      get_env: fn
        :http_mock_pal, :routers, [] -> []
      end do
      usages = HttpMockPalDiscovery.discover_usages(any: "this is unused")

      assert usages == []
    end
  end
end
