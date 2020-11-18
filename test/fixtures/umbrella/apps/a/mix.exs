defmodule MixUnused.Fixtures.Umbrella.AProject do
  use Mix.Project

  def project do
    [
      app: :a,
      compilers: [:unused | Mix.compilers()],
      version: "0.0.0"
    ]
  end
end
