defmodule MixUnused.MixProject do
  use Mix.Project

  @source_url "https://github.com/hauleth/mix_unused"
  @version "0.4.0"

  def project do
    [
      app: :mix_unused,
      description: "Mix compiler tracer for detecting unused public functions",
      version: @version,
      elixir: "~> 1.13",
      package: [
        licenses: ~w[MIT],
        links: %{
          "Changelog" => "https://hexdocs.pm/mix_unused/changelog.html",
          "Sponsor" => "https://github.com/sponsors/hauleth",
          "GitHub" => @source_url
        }
      ],
      deps: [
        {:covertool, "~> 2.0", only: :test},
        {:credo, ">= 0.0.0", only: :dev, runtime: false},
        {:dialyxir, "~> 1.0", only: :dev, runtime: false},
        {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
        {:libgraph, ">= 0.0.0"},
        {:mock, "~> 0.3.7", only: :test},
        {:stream_data, ">= 0.0.0", only: [:test, :dev]}
      ],
      docs: [
        extras: [
          "README.md": [title: "Overview"],
          "CHANGELOG.md": [],
          LICENSE: [title: "License"],
          "guides/unreachable-analyzer.md": [
            title: "Using the Unreachable analyzer"
          ]
        ],
        groups_for_extras: [
          Guides: ~r"guides/"
        ],
        groups_for_modules: [
          "Usages discovery": ~r"MixUnused.Analyzers.Unreachable.Usages.\w+$"
        ],
        nest_modules_by_prefix: [
          MixUnused.Analyzers,
          MixUnused.Analyzers.Unreachable.Usages
        ],
        main: "Mix.Tasks.Compile.Unused",
        source_url: @source_url,
        source_url: "v#{@version}",
        formatters: ["html"]
      ],
      test_coverage: [tool: :covertool]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:mix, :logger]
    ]
  end
end
