defmodule MixUnused.MixProject do
  use Mix.Project

  def project do
    [
      app: :mix_unused,
      description: "Mix compiler tracer for detecting unused public functions",
      version: "0.1.0",
      elixir: "~> 1.10",
      package: [
        licenses: ~w[MPL-2.0],
        links: %{
          "GitHub" => "https://github.com/hauleth/mix_unused"
        }
      ],
      deps: [
        {:ex_doc, ">= 0.0.0", only: :dev},
        {:dialyxir, "~> 1.0", only: :dev}
      ],
      docs: [
        main: "Mix.Tasks.Compile.Unused"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:mix, :logger]
    ]
  end
end
