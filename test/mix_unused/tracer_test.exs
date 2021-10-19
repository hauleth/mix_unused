defmodule MixUnused.TracerTest do
  use ExUnit.Case

  @subject MixUnused.Tracer

  doctest @subject

  ExUnit.Case.register_attribute(__MODULE__, :code, [])

  setup ctx do
    options = Code.compiler_options()
    name = Module.concat([__MODULE__, Test, ctx.test])

    Application.put_env(:mix_unused, :set, Remote)

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
           def test do
             &__MODULE__.foo/0
           end

           def foo(), do: :ok
         end)
  test "contains information about function returned by remote reference", ctx do
    assert {ctx.module_name, :foo, 0} in @subject.get_calls()
  end

  @code (quote do
           def test do
             &foo/0
           end

           def foo(), do: :ok
         end)
  test "contains information about function returned by local reference", ctx do
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

  @code (quote do
           defmacro foo(), do: :ok

           def test do
             foo()
           end
         end)
  test "contains information about called local macros", ctx do
    assert {ctx.module_name, :foo, 0} in @subject.get_calls()
  end

  @code (quote do
           require Logger

           def test do
             Logger.info("foo")
           end
         end)
  test "contains information about called remote macros" do
    assert {Logger, :info, 1} in @subject.get_calls()
  end

  @code (quote do
           import Logger

           def test do
             info("foo")
           end
         end)
  test "contains information about called imported macros" do
    assert {Logger, :info, 1} in @subject.get_calls()
  end

  @code (quote do
           @attr Remote

           def test do
             @attr.foo()
           end
         end)
  test "contains information about remote calls using module attributes" do
    assert {Remote, :foo, 0} in @subject.get_calls()
  end

  @code (quote do
           @attr Application.compile_env(:mix_unused, :unset, Remote)

           def test do
             @attr.foo()
           end
         end)
  test "contains information about remote calls using dynamic module attributes (default)" do
    assert {Remote, :foo, 0} in @subject.get_calls()
  end

  @code (quote do
           @attr Application.compile_env(:mix_unused, :set, NotRemote)

           def test do
             @attr.foo()
           end
         end)
  test "contains information about remote calls using dynamic module attributes" do
    assert {Remote, :foo, 0} in @subject.get_calls()
  end

  @code (quote do
           def test do
             %MapSet{}
           end
         end)
  test "struct expansion add macros for struct" do
    assert {MapSet, :__struct__, 0} in @subject.get_calls()
    assert {MapSet, :__struct__, 1} in @subject.get_calls()
  end
end
