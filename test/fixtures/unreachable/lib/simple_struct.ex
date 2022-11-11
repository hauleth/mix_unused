defmodule SimpleStruct do
  defstruct [:foo]

  def foo(%__MODULE__{foo: foo}, _default_arg \\ nil), do: foo
end
