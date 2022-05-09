defmodule MixUnused.Analyzers.Unreachable.Usages.AmqpxConsumersDiscovery do
  @moduledoc """
  Discovers the consumers configured for the [amqpx library](https://hex.pm/packages/amqpx).
  """

  @behaviour MixUnused.Analyzers.Unreachable.Usages

  @impl true
  def discover_usages(_opts) do
    app = Mix.Project.config()[:app]

    for %{handler_module: module} <- Application.get_env(app, :consumers, []) do
      [
        {module, :setup, 1},
        {module, :handle_message, 3}
      ]
    end
    |> List.flatten()
  end
end
