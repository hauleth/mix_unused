defmodule MixUnused.MixProject do
  use Mix.Project

  def project do
    [
      app: :mix_unused,
      description: "Mix compiler tracer for detecting unused public functions",
      version: "0.2.0",
      elixir: "~> 1.10",
      package: [
        licenses: ~w[MIT],
        links: %{
          "GitHub" => "https://github.com/hauleth/mix_unused"
        }
      ],
      deps: [
        {:credo, ">= 0.0.0", only: :dev, runtime: false},
        {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
        {:dialyxir, "~> 1.0", only: :dev, runtime: false}
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
