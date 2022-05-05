defmodule MixUnused.Analyzers.Unreachable.Entrypoints.AmqpxConsumersDiscovery do
  @moduledoc """
  Discovers the consumers configured for the [amqpx library](https://hex.pm/packages/amqpx).
  """

  @behaviour MixUnused.Analyzers.Unreachable.Entrypoints

  @impl true
  def discover_entrypoints(_opts) do
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
