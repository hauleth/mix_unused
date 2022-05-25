defmodule MixUnused.Analyzers.Unreachable.Usages.Helpers.Aliases do
  @moduledoc false

  @type t :: %{module() => module()}

  @spec new(Macro.t()) :: t()
  def new(ast) do
    for node <- Macro.prewalker(ast), reduce: %{} do
      state ->
        case node do
          # alias Path.To.Module
          {:alias, _, [{:__aliases__, _, atoms}]} ->
            as_module = Module.concat(Enum.take(atoms, -1))
            Map.put(state, as_module, Module.concat(atoms))

          # alias Path.To.Module, as: Mod
          {:alias, _,
           [
             {:__aliases__, _, atoms},
             [as: {:__aliases__, _, as_atoms}]
           ]} ->
            as_module = Module.concat(as_atoms)
            Map.put(state, as_module, Module.concat(atoms))

          _ ->
            state
        end
    end
  end

  @spec resolve(t(), [atom]) :: module()
  def resolve(aliases, atoms) do
    {base_atom, rest} = Enum.split(atoms, 1)
    base_module = Module.concat(base_atom)
    Module.concat([Map.get(aliases, base_module, base_module) | rest])
  end
end
