defmodule MixUnused.MixProject do
  use Mix.Project

  @source_url "https://github.com/hauleth/mix_unused"
  @version "0.3.0"

  def project do
    [
      app: :mix_unused,
      description: "Mix compiler tracer for detecting unused public functions",
      version: @version,
      elixir: "~> 1.10",
      package: [
        licenses: ~w[MIT],
        links: %{
          "Changelog" => "https://hexdocs.pm/mix_unused/changelog.html",
          "GitHub" => @source_url
        }
      ],
      deps: [
        {:credo, ">= 0.0.0", only: :dev, runtime: false},
        {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
        {:dialyxir, "~> 1.0", only: :dev, runtime: false}
      ],
      docs: [
        extras: [
          "CHANGELOG.md": [],
          LICENSE: [title: "License"],
          "README.md": [title: "Overview"]
        ],
        # main: "Mix.Tasks.Compile.Unused",
        main: "readme",
        source_url: @source_url,
        source_url: "v#{@version}",
        formatters: ["html"]
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
