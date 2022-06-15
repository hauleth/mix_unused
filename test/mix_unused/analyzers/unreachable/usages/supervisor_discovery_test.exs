defmodule MixUnused.Analyzers.Unreachable.Usages.SupervisorDiscoveryTest do
  use ExUnit.Case

  alias MixUnused.Analyzers.Unreachable.Usages.Context
  alias MixUnused.Analyzers.Unreachable.Usages.SupervisorDiscovery

  alias MixUnused.Meta

  import Mock

  test "it discovers (exported) genserver callbacks defined by supervisor children" do
    with_mock File,
      read!: fn
        "supervisor.ex" -> ~s{
          defmodule MyApp.MySupervisor do

            alias MyApp.FooModule.AnotherGenserver

            use Supervisor

            def start_link(opts) do
              Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
            end

            def init(args) do
              children = [MyApp.AGenServer, AnotherGenserver]

              opts = [strategy: :one_for_one, max_restarts: 6]
              Supervisor.init(children, opts)
            end
          end
        }
      end do
      usages =
        SupervisorDiscovery.discover_usages(%Context{
          exports: %{
            {MyApp.AGenServer, :handle_call, 3} => %Meta{
              file: "a_genserver.ex"
            },
            {AnotherGenserver, :handle_info, 2} => %Meta{},
            {MyApp.MySupervisor, :init, 1} => %Meta{
              file: "supervisor.ex"
            }
          }
        })

      assert {MyApp.MySupervisor, :init, 1} in usages
      assert {MyApp.AGenServer, :handle_call, 3} in usages
      assert {AnotherGenserver, :handle_info, 2} in usages
      assert 3 == length(usages)
    end
  end
end
