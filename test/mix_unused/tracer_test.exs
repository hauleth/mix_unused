defmodule MixUnused.TracerTest do
  use ExUnit.Case

  @subject MixUnused.Tracer

  doctest @subject

  ExUnit.Case.register_attribute(__MODULE__, :code, [])

  defmacrop find_call(calls, mfa, env \\ quote(do: %{})) do
    quote do
      Enum.any?(unquote(calls), &match?({unquote(mfa), unquote(env)}, &1))
    end
  end

  describe "code compilation" do
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

      assert %{^name => calls} = @subject.get_data()

      {:ok, module_name: name, calls: calls}
    end

    @code (quote do
             def test do
               Remote.foo()
             end
           end)
    test "contains information about called remote function", ctx do
      assert find_call(ctx.calls, {Remote, :foo, 0})
    end

    @code (quote do
             def test do
               foo()
             end

             def foo(), do: :ok
           end)
    test "contains information about called local public function", ctx do
      name = ctx.module_name
      assert find_call(ctx.calls, {^name, :foo, 0})
    end

    @code (quote do
             def test do
               &__MODULE__.foo/0
             end

             def foo(), do: :ok
           end)
    test "contains information about function returned by remote reference",
         ctx do
      name = ctx.module_name
      assert find_call(ctx.calls, {^name, :foo, 0})
    end

    @code (quote do
             def test do
               &foo/0
             end

             def foo(), do: :ok
           end)
    test "contains information about function returned by local reference",
         ctx do
      name = ctx.module_name
      assert find_call(ctx.calls, {^name, :foo, 0})
    end

    @code (quote do
             import String

             def test do
               first("foo")
             end
           end)
    test "contains information about called imported function", ctx do
      assert find_call(ctx.calls, {String, :first, 1})
    end

    @code (quote do
             defmacro foo(), do: :ok

             def test do
               foo()
             end
           end)
    test "contains information about called local macros", ctx do
      name = ctx.module_name
      assert find_call(ctx.calls, {^name, :foo, 0})
    end

    @code (quote do
             require Logger

             def test do
               Logger.info("foo")
             end
           end)
    test "contains information about called remote macros", ctx do
      assert find_call(ctx.calls, {Logger, :info, 1})
    end

    @code (quote do
             import Logger

             def test do
               info("foo")
             end
           end)
    test "contains information about called imported macros", ctx do
      assert find_call(ctx.calls, {Logger, :info, 1})
    end

    @code (quote do
             @attr Remote

             def test do
               @attr.foo()
             end
           end)
    test "contains information about remote calls using module attributes", ctx do
      assert find_call(ctx.calls, {Remote, :foo, 0})
    end

    @code (quote do
             @attr Application.compile_env(:mix_unused, :unset, Remote)

             def test do
               @attr.foo()
             end
           end)
    test "contains information about remote calls using dynamic module attributes (default)", ctx do
      assert find_call(ctx.calls, {Remote, :foo, 0})
    end

    @code (quote do
             @attr Application.compile_env(:mix_unused, :set, NotRemote)

             def test do
               @attr.foo()
             end
           end)
    test "contains information about remote calls using dynamic module attributes", ctx do
      assert find_call(ctx.calls, {Remote, :foo, 0})
    end

    @code (quote do
             def test do
               %MapSet{}
             end
           end)
    test "struct expansion add macros for struct", ctx do
      assert find_call(ctx.calls, {MapSet, :__struct__, 0})
      assert find_call(ctx.calls, {MapSet, :__struct__, 1})
    end

    @code (quote do
             def foo, do: :ok

             def a do
               foo()
             end

             def b do
               foo()
             end
           end)
    test "stores calling function", ctx do
      name = ctx.module_name
      assert find_call(ctx.calls, {^name, :foo, 0}, %{function: {:a, 0}})
      assert find_call(ctx.calls, {^name, :foo, 0}, %{function: {:b, 0}})
    end
  end
end
