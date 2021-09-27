defmodule MixUnused.Tracer do
  @moduledoc false

  use GenServer

  @tab __MODULE__.Functions

  @doc false
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      restart: :transient
    }
  end

  @doc false
  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @remote ~w[
      imported_function
      remote_function
      imported_macro
      remote_macro
    ]a

  def trace({action, _meta, module, name, arity}, env)
      when action in @remote do
    add_call(module, name, arity, env)

    :ok
  end

  @local ~w[
      local_function
      local_macro
    ]a

  def trace({action, _meta, name, arity}, env)
      when action in @local do
    add_call(env.module, name, arity, env)

    :ok
  end

  def trace(_event, _env), do: :ok

  @spec add_call(module(), atom(), arity(), Macro.Env.t()) :: :ok
  defp add_call(m, f, a, env) do
    _ = :ets.insert_new(@tab, {{env.module, {m, f, a}}, []})

    :ok
  end

  @spec get_data() :: %{module() => [mfa()]}
  def get_data do
    @tab
    |> :ets.select([{{:"$1", :_}, [], [:"$1"]}])
    |> Enum.reduce(%{}, fn {mod, mfa}, acc ->
      Map.update(acc, mod, [mfa], &[mfa | &1])
    end)
  end

  @spec get_calls() :: [mfa()]
  def get_calls do
    :ets.select(@tab, [{{{:_, :"$1"}, :_}, [], [:"$1"]}])
  end

  def stop, do: GenServer.call(__MODULE__, :stop)

  @impl true
  def init(_args) do
    _ = :ets.new(@tab, [:public, :named_table, :set, {:write_concurrency, true}])

    {:ok, []}
  end

  @impl true
  def handle_call(:stop, _, state), do: {:stop, :normal, :ok, state}
end
