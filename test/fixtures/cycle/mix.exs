defmodule MixUnused.Fixtures.UnleanProject do
  use Mix.Project

  def project do
    [
      app: :cycle,
      compilers: [:unused | Mix.compilers()],
      version: "0.0.0",
      unused: [
        ignore: [
          {Foo, ~r/^(baz)$/},
          {Bar, ~r/^(foo)$/},
          {Baz, ~r/^(bar)$/}
        ]
      ]
    ]
  end
end
