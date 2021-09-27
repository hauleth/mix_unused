defmodule MixUnused.TracerTest do
  use ExUnit.Case

  @subject MixUnused.Tracer

  doctest @subject

  ExUnit.Case.register_attribute(__MODULE__, :code, [])

  setup ctx do
    options = Code.compiler_options()
    name = Module.concat([__MODULE__, Test, ctx.test])

    try do
      start_supervised!(@subject)

      quoted =
        quote do
          defmodule unquote(name) do
            unquote(ctx.registered.code)
          end
        end

      Code.put_compiler_option(:tracers, [@subject])
      Code.put_compiler_option(:warnings_as_errors, false)
      Code.compile_quoted(quoted, Atom.to_string(ctx.test))
    after
      Code.compiler_options(options)
    end

    {:ok, module_name: name}
  end

  @code (quote do
           def test do
             Remote.foo()
           end
         end)
  test "contains information about called remote function" do
    assert {Remote, :foo, 0} in @subject.get_calls()
  end

  @code (quote do
           def test do
             foo()
           end

           def foo(), do: :ok
         end)
  test "contains information about called local public function", ctx do
    assert {ctx.module_name, :foo, 0} in @subject.get_calls()
  end

  @code (quote do
           import String

           def test do
             first("foo")
           end
         end)
  test "contains information about called imported function" do
    assert {String, :first, 1} in @subject.get_calls()
  end
end
