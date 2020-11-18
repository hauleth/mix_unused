defmodule MixUnused.MixProject do
  use Mix.Project

  def project do
    [
      app: :mix_unused,
      version: "0.1.0",
      elixir: "~> 1.10",
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:mix, :logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps, do: []
end
