defmodule SimpleServer do
  # We use `gen_server` directly here as `use GenServer` also defines
  # `child_spec` which will cause error
  @behaviour :gen_server

  def init(_), do: {:ok, []}

  def handle_call(%SimpleStruct{} = s, _ref, state),
    do: {:reply, :ok, SimpleStruct.foo(s, nil) ++ state}

  def handle_cast(_msg, state), do: {:noreply, state}
end
