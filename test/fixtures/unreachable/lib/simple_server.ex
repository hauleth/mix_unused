defmodule SimpleServer do
  # this module has been declared as entrypoint

  use GenServer

  def init(_), do: {:ok, []}

  def handle_call(%SimpleStruct{} = struct, _ref, state) do
    {:reply, {:ok, handle(struct)}, state}
  end

  def handle_cast(_msg, state), do: {:noreply, state}

  defp handle(struct) do
    SimpleModule.use_foo(struct)
  end
end
