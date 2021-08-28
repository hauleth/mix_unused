defmodule MixUnused.Tracer do
  use GenServer

  @tab __MODULE__.Functions

  def start_link() do
    with {:error, {:already_started, pid}} <-
           GenServer.start_link(__MODULE__, [], name: __MODULE__) do
      :ets.delete_all_objects(@tab)

      {:ok, pid}
    end
  end

  @events ~w[imported_function local_function remote_function]a

  def trace({action, _meta, module, name, arity}, env) when action in @events do
    add_call(module, name, arity, env)
  end

  def trace(_event, _env), do: :ok

  defp add_call(m, f, a, env) do
    _ = :ets.insert_new(@tab, {{env.module, {m, f, a}}, []})

    :ok
  end

  def get_data do
    :ets.select(@tab, [{{:"$1", :_}, [], [:"$1"]}])
    |> Enum.reduce(%{}, fn {mod, mfa}, acc ->
      Map.update(acc, mod, [mfa], &[mfa | &1])
    end)
  end

  def get_calls do
    :ets.select(@tab, [{{{:_, :"$1"}, :_}, [], [:"$1"]}])
  end

  def stop, do: GenServer.call(__MODULE__, :stop)

  def init(_args) do
    _ = :ets.new(@tab, [:public, :named_table, :set, {:write_concurrency, true}])

    {:ok, []}
  end

  def handle_call(:stop, _, state), do: {:stop, :normal, :ok, state}
end
