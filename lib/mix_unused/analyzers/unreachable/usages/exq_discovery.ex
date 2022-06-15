defmodule MixUnused.Analyzers.Unreachable.Usages.ExqDiscovery do
  @moduledoc """
  Discovers functions called by [Exq](https://hex.pm/packages/exq).
  """

  alias MixUnused.Analyzers.Unreachable.Usages.Context
  alias MixUnused.Analyzers.Unreachable.Usages.Helpers.Aliases
  alias MixUnused.Analyzers.Unreachable.Usages.Helpers.Source

  @behaviour MixUnused.Analyzers.Unreachable.Usages

  @impl true
  def discover_usages(%Context{calls: calls, exports: exports}) do
    for module <- modules_calling_exq(calls),
        source <- Source.read_module_source(module, exports),
        mfa <- functions_called_by_exq(source),
        uniq: true,
        do: mfa
  end

  defp modules_calling_exq(calls) do
    for m <- [Exq, Exq.Enqueuer],
        {f, a} <- [
          {:enqueue, 4},
          {:enqueue_at, 5},
          {:enqueue_in, 5}
        ],
        # every function has an additional optional argument
        a <- [a, a + 1],
        %Graph.Edge{v1: {caller, _f, _a}} <- Graph.in_edges(calls, {m, f, a}),
        do: caller
  end

  defp functions_called_by_exq(ast) do
    aliases = Aliases.new(ast)

    for node <- Macro.prewalker(ast),
        {module, ariety} <- [function_called_by_exq(node)],
        {:ok, module} <- [Aliases.resolve(aliases, module)],
        do: {module, :perform, ariety}
  end

  defp function_called_by_exq(ast) do
    case ast do
      # Exq.enqueue(pid, queue, worker, ...)
      {{:., _, [{:__aliases__, _, [:Exq | _]}, :enqueue]}, _,
       [
         _pid,
         _queue,
         _worker = module,
         args | _
       ]}
      when is_list(args) ->
        {module, length(args)}

      # Exq.enqueue_at(pid, queue, time, worker, ...)
      # Exq.enqueue_in(pid, queue, offset, worker, ...)
      {{:., _, [{:__aliases__, _, [:Exq | _]}, f]}, _,
       [
         _pid,
         _queue,
         _time_or_offset,
         _worker = module,
         args | _
       ]}
      when f in [:enqueue_at, :enqueue_in] and is_list(args) ->
        {module, length(args)}

      _ ->
        nil
    end
  end
end
