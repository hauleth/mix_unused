defmodule MixUnused do
  use GenServer

  @tab __MODULE__.Functions

  def start_link() do
    with {:error, {:already_started, pid}} <-
           GenServer.start_link(__MODULE__, [], name: __MODULE__) do
      :ets.delete_all_objects(@tab)

      {:ok, pid}
    end
  end

  def trace({action, _meta, module, name, arity}, _env)
      when action in ~w[imported_function local_function remote_function]a,
      do: add_call(module, name, arity)

  def trace(_event, _env), do: :ok

  defp add_call(m, f, a) do
    _ = :ets.insert_new(@tab, {{m, f, a}})

    :ok
  end

  def get_calls, do: :ets.select(@tab, [{{:"$1"}, [], [:"$1"]}])

  def init(_args) do
    _ = :ets.new(@tab, [:public, :named_table, :set, {:write_concurrency, true}])

    {:ok, []}
  end
end
