defmodule MixUnused.MixProject do
  use Mix.Project

  @source_url "https://github.com/hauleth/mix_unused"
  @version "0.4.1"

  def project do
    [
      app: :mix_unused,
      description: "Mix compiler tracer for detecting unused public functions",
      version: @version,
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: [
        licenses: ~w[MIT],
        links: %{
          "Changelog" => "https://hexdocs.pm/mix_unused/changelog.html",
          "Sponsor" => "https://github.com/sponsors/hauleth",
          "GitHub" => @source_url
        }
      ],
      deps: [
        {:libgraph, ">= 0.0.0"},
        {:credo, ">= 0.0.0", only: :dev, runtime: false},
        {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
        {:dialyxir, "~> 1.0", only: :dev, runtime: false},
        {:stream_data, ">= 0.0.0", only: [:test, :dev]},
        {:covertool, "~> 2.0", only: :test}
      ],
      docs: [
        extras: [
          "CHANGELOG.md": [],
          LICENSE: [title: "License"]
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

  defp elixirc_paths(:test), do: ~w[lib test/support]
  defp elixirc_paths(_), do: ~w[lib]
end
