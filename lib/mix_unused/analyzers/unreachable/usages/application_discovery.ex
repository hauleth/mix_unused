defmodule MixUnused.Analyzers.Unreachable.Usages.ApplicationDiscovery do
  @moduledoc """
  Discovers the callbacks of the current application.
  """

  alias MixUnused.Analyzers.Unreachable.Usages.Helpers.Behaviours

  @behaviour MixUnused.Analyzers.Unreachable.Usages

  @callbacks Behaviours.callbacks(Application)

  @impl true
  def discover_usages(_context) do
    app = Mix.Project.config()[:app]

    case Application.spec(app, :mod) do
      {module, _env} ->
        for {_, f, a} <- @callbacks, do: {module, f, a}

      _ ->
        []
    end
  end
end
