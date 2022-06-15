defmodule MixUnused.Analyzers.Unreachable.Usages.AmqpxConsumersDiscoveryTest do
  use ExUnit.Case

  alias MixUnused.Analyzers.Unreachable.Usages.AmqpxConsumersDiscovery

  import Mock

  test "it discovers the amqpx consumer modules and respective :setup/1, :handle_message/3 as defined in the application env" do
    with_mocks [
      {Mix.Project, [], [config: fn -> [app: :my_app, version: 0.1] end]},
      {Application, [],
       [
         get_env: fn
           :my_app, :consumers, [] ->
             [
               %{
                 handler_module: MyApplication.MyFirstConsumer,
                 backoff: 10_000
               },
               %{
                 handler_module: MyApplication.MySecondConsumer,
                 backoff: 10_000
               }
             ]
         end
       ]}
    ] do
      usages = AmqpxConsumersDiscovery.discover_usages(nil)

      assert {MyApplication.MyFirstConsumer, :setup, 1} in usages
      assert {MyApplication.MyFirstConsumer, :handle_message, 3} in usages
      assert {MyApplication.MySecondConsumer, :setup, 1} in usages
      assert {MyApplication.MySecondConsumer, :handle_message, 3} in usages
      assert 4 == length(usages)
    end
  end

  test "no usages discovered if no consumer modules are defined in the application env" do
    with_mocks [
      {Mix.Project, [], [config: fn -> [app: :my_app, version: 0.1] end]},
      {Application, [],
       [
         get_env: fn
           :my_app, :consumers, [] -> []
         end
       ]}
    ] do
      usages = AmqpxConsumersDiscovery.discover_usages(nil)

      assert usages == []
    end
  end
end
