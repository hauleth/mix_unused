defmodule MixUnused.Fixtures.CleanProject do
  use Mix.Project

  def project do
    [
      app: :clean,
      compilers: [:unused] ++ Mix.compilers(),
      version: "0.0.0"
    ]
  end
end
