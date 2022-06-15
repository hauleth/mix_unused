defmodule MixUnused.Analyzers.Unreachable.Usages.HttpMockPalDiscovery do
  @moduledoc """
  Discovers the mock modules configured for the [http_mock_pal library](https://hex.pm/packages/http_mock_pal).
  """

  @behaviour MixUnused.Analyzers.Unreachable.Usages

  @impl true
  def discover_usages(_context) do
    for {module, _} <- Application.get_env(:http_mock_pal, :routers, []) do
      {module, :call, 2}
    end
  end
end
