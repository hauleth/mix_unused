defmodule MixUnused.Fixtures.UnleanProject do
  use Mix.Project

  def project do
    [
      app: :unclean,
      compilers: [:unused] ++ Mix.compilers(),
      version: "0.0.0",
      unused: [
        ignore: [
          {Foo, :bar, 0}
        ]
      ]
    ]
  end
end
