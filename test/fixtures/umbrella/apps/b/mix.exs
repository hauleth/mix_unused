defmodule MixUnused.Fixtures.Umbrella.BProject do
  use Mix.Project

  def project do
    [
      app: :b,
      compilers: [:unused | Mix.compilers()],
      version: "0.0.0",
      deps: [{:a, in_umbrella: true}]
    ]
  end
end
