defmodule MixUnused.Analyzers.Unreachable.Usages.Helpers.SourceTest do
  use ExUnit.Case

  alias MixUnused.Analyzers.Unreachable.Usages.Helpers.Source

  alias MixUnused.Meta

  import Mock

  test "read sources with suffix correctly works on nested paths" do
    with_mock File,
      read!: fn
        "suffix.ex" -> ~s[Flat]
        "foo/bar/suffix.ex" -> ~s[Path]
        "foo/bar/suffixFoo.ex" -> ~s[Don't read this]
      end do
      quoted_sources =
        Source.read_sources_with_suffix("suffix.ex", %{
          {Pippo, :pippo, 0} => %Meta{file: "suffix.ex"},
          {Pluto, :pluto, 1} => %Meta{file: "foo/bar/suffix.ex"}
        })

      assert Code.string_to_quoted!("Flat") in quoted_sources
      assert Code.string_to_quoted!("Path") in quoted_sources
      assert 2 == length(quoted_sources)
    end
  end

  test "duplicate appearances of the same file are not repeated in the output" do
    with_mock File,
      read!: fn
        "suffix.ex" -> ~s[Flat]
        "foo/bar/suffixFoo.ex" -> ~s[Don't read this]
      end do
      quoted_sources =
        Source.read_sources_with_suffix("suffix.ex", %{
          {Pippo, :pippo, 0} => %Meta{file: "suffix.ex"},
          {PippoFoo, :call, 3} => %Meta{file: "suffix.ex"}
        })

      assert Code.string_to_quoted!("Flat") in quoted_sources
      assert 1 == length(quoted_sources)
    end
  end

  test "read_module_source correctly resolves the module file" do
    with_mock File,
      read!: fn
        "foo_module.ex" -> "BarContent"
      end do
      quoted_source =
        Source.read_module_source(FooModule, %{
          {FooModule, :pippo, 0} => %Meta{file: "foo_module.ex"}
        })

      assert [Code.string_to_quoted!("BarContent")] == quoted_source
    end
  end
end
