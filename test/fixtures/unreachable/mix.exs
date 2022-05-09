defmodule MixUnused.Fixtures.UnreachableProject do
  use Mix.Project

  def project do
    [
      app: :unreachable,
      compilers: [:unused | Mix.compilers()],
      version: "0.0.0",
      unused: [
        checks: [
          {MixUnused.Analyzers.Unreachable,
           %{
             usages: [
               SimpleServer
             ]
           }}
        ]
      ]
    ]
  end
end
