defmodule SimpleServer do
  # We use `gen_server` directly here as `use GenServer` also defines
  # `child_spec` which will cause error
  @behaviour :gen_server

  def init(_), do: {:ok, []}

  def handle_call(_msg, _ref, state), do: {:reply, :ok, state}

  def handle_cast(_msg, state), do: {:noreply, state}
end
