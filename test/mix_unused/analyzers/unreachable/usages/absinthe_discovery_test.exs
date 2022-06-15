defmodule MixUnused.Analyzers.Unreachable.Usages.AbsintheDiscoveryTest do
  use ExUnit.Case

  alias MixUnused.Analyzers.Unreachable.Usages.Context
  alias MixUnused.Analyzers.Unreachable.Usages.AbsintheDiscovery
  alias MixUnused.Meta

  import Mock

  test "it discovers generated function" do
    with_mock File,
      read!: fn
        "schema.ex" -> ~s[
          defmodule Schema do
          end
        ]
        "types.ex" -> ~s[
          defmodule Schema.Types do
          end
        ]
      end do
      usages =
        AbsintheDiscovery.discover_usages(%Context{
          exports: %{
            {Schema, :__absinthe_function__, 1} => %Meta{
              file: "schema.ex"
            },
            {Schema.Types, :__absinthe_function__, 1} => %Meta{
              file: "types.ex"
            }
          }
        })

      assert {Schema, :__absinthe_function__, 1} in usages
      assert {Schema.Types, :__absinthe_function__, 1} in usages
      assert 2 == length(usages)
    end
  end

  test "it discovers used middlewares" do
    with_mock File,
      read!: fn
        "schema.ex" -> ~s[
          defmodule Schema do
            use Absinthe.Schema

            import_types Schema.Types

            alias App.GraphQL.Authorization.RequirePermission

            query do
              field :brands, list_of(:brand) do
                middleware RequirePermission, "read"
              end

              field :vehicles, list_of(:vehicle) do
                middleware RequirePermission, "read"
                middleware App.GraphQL.Logger
              end
            end
          end
        ]
        "types.ex" -> ~s[
          defmodule Schema.Types do
            use Absinthe.Schema

            object :model do
              field :speed, non_null(:integer) do
                middleware App.GraphQL.SpeedLogger
              end
            end
          end
        ]
      end do
      usages =
        AbsintheDiscovery.discover_usages(%Context{
          exports: %{
            {Schema, :__absinthe_function__, 1} => %Meta{
              file: "schema.ex"
            },
            {Schema.Types, :__absinthe_function__, 1} => %Meta{
              file: "types.ex"
            }
          }
        })

      assert {App.GraphQL.Logger, :call, 2} in usages
      assert {App.GraphQL.Authorization.RequirePermission, :call, 2} in usages
      assert {App.GraphQL.SpeedLogger, :call, 2} in usages
      assert 5 == length(usages)
    end
  end
end
