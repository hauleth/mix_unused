defmodule MixUnused.Fixtures.TwoModsProject do
  use Mix.Project

  def project do
    [
      app: :two_mods,
      compilers: [:unused | Mix.compilers()],
      version: "0.0.0",
      unused: [
        ignore: [
          {Bar, :bar, 0}
        ]
      ]
    ]
  end
end
