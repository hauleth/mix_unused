defmodule MixUnused.Analyzers.Unreachable.Entrypoints.HttpMockPalDiscovery do
  @moduledoc """
  Discovers the mock modules configured for the http_mock_pal library.
  """

  @behaviour MixUnused.Analyzers.Unreachable.Entrypoints

  @impl true
  def discover_entrypoints(_opts) do
    for {module, _} <- Application.get_env(:http_mock_pal, :routers, []) do
      {module, :call, 2}
    end
  end
end
