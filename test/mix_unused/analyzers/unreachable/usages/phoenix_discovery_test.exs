defmodule MixUnused.Analyzers.Unreachable.Usages.PhoenixDiscoveryTest do
  use ExUnit.Case

  alias MixUnused.Analyzers.Unreachable.Usages.PhoenixDiscovery
  alias MixUnused.Meta

  import Mock

  # TODO: add alias
  test "it discovers http method handlers defined in controllers" do
    with_mock File,
      read!: fn "fooweb/router.ex" -> ~s[
        defmodule MyPhoenixApp.Router do
          @moduledoc false

          alias MyPhoenixApp.Controllers.CartController

          use MyPhoenixApp, :router

          scope "/" do
            get "/", MyPhoenixApp.PageController, :index
            post "/user", MyPhoenixApp.UsersController, :create_user
            patch "/cart", CartController.Pippo, :update_cart
          end
        end
      ] end do
      usages =
        PhoenixDiscovery.discover_usages(
          exports: %{
            {MyPhoenixApp.PageController, :index, 2} => %Meta{
              file: "fooweb/router.ex"
            }
          }
        )

      assert {MyPhoenixApp.PageController, :index, 2} in usages
      assert {MyPhoenixApp.UsersController, :create_user, 2} in usages

      assert {MyPhoenixApp.Controllers.CartController.Pippo, :update_cart, 2} in usages

      assert 3 == length(usages)
    end
  end

  test "it discovers callback functions implemented by custom plugs in pipelines" do
    with_mock File,
      read!: fn "router.ex" -> ~s|
        defmodule MyPhoenixApp.Router do
          @moduledoc false

          alias MyPhoenixApp.Plugs.ParametricPlugs, as: ParPlug


          use MyPhoenixApp, :router

          pipeline :browser do
            plug :accepts, ["html"]
            plug :fetch_session
            plug MyPhoenixPlug
            plug ParPlug, %{key_1: "v1", key_2: "v2"}
            plug ParPlug.SubPlug, ["a", "b"]
          end

          scope "/" do
            pipe_through(:browser)
          end
        end
      | end do
      usages =
        PhoenixDiscovery.discover_usages(
          exports: %{
            {MyPhoenixApp.PageController, :index, 2} => %Meta{file: "router.ex"}
          }
        )

      assert {MyPhoenixPlug, :init, 1} in usages
      assert {MyPhoenixPlug, :call, 2} in usages
      assert {MyPhoenixApp.Plugs.ParametricPlugs, :init, 1} in usages
      assert {MyPhoenixApp.Plugs.ParametricPlugs, :call, 2} in usages
      assert {MyPhoenixApp.Plugs.ParametricPlugs.SubPlug, :init, 1} in usages
      assert {MyPhoenixApp.Plugs.ParametricPlugs.SubPlug, :call, 2} in usages
      assert 6 == length(usages)
    end
  end
end
