defmodule MixUnused.Analyzers.Unreachable.Usages.ExqDiscoveryTest do
  use ExUnit.Case

  alias MixUnused.Analyzers.Unreachable.Usages.Context
  alias MixUnused.Analyzers.Unreachable.Usages.ExqDiscovery
  alias MixUnused.Meta

  import Mock

  test "it discovers functions called by Exq (via enqueue)" do
    with_mock File,
      read!: fn
        "example.ex" -> ~s{
            defmodule Example do
              alias Example.Consumer

              def f do
                Exq.enqueue(Exq, "queue", Consumer, [1, 2])
              end
            end
          }
      end do
      usages =
        ExqDiscovery.discover_usages(%Context{
          calls:
            Graph.new()
            |> Graph.add_edge({Example, :f, 0}, {Exq, :enqueue, 4}),
          exports: %{
            {Example, :f, 0} => %Meta{file: "example.ex"}
          }
        })

      assert [{Example.Consumer, :perform, 2}] == usages
    end
  end

  test "it discovers functions called by Exq (via enqueue_in)" do
    with_mock File,
      read!: fn
        "example.ex" -> ~s{
            defmodule Example do
              alias Example.Consumer

              def f do
                Exq.enqueue_in(Exq, "queue", 1000, Consumer, [1], max_retries: 2)
              end
            end
          }
      end do
      usages =
        ExqDiscovery.discover_usages(%Context{
          calls:
            Graph.new()
            |> Graph.add_edge({Example, :f, 0}, {Exq, :enqueue_in, 6}),
          exports: %{
            {Example, :f, 0} => %Meta{file: "example.ex"}
          }
        })

      assert [{Example.Consumer, :perform, 1}] == usages
    end
  end

  test "it discovers functions called by Exq (via enqueue_at)" do
    with_mock File,
      read!: fn
        "example.ex" -> ~s{
            defmodule Example do
              alias Example.Consumer

              def f do
                Exq.Enqueuer.enqueue_at(Exq.Enqueuer, "queue", DateTime.now(), __MODULE__, [])
              end
            end
          }
      end do
      usages =
        ExqDiscovery.discover_usages(%Context{
          calls:
            Graph.new()
            |> Graph.add_edge({Example, :f, 0}, {Exq, :enqueue_at, 5}),
          exports: %{
            {Example, :f, 0} => %Meta{file: "example.ex"}
          }
        })

      assert [{Example, :perform, 0}] == usages
    end
  end
end
