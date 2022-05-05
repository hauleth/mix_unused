defmodule SimpleMacro do
  defmacro __using__(_opts) do
    quote do
      def f, do: :f
      def g, do: :g
    end
  end
end
