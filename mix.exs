defmodule Rustic.Result.MixProject do
  use Mix.Project

  def project do
    [
      app: :rustic_result,
      version: "0.4.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),

      name: "Rustic.Result",
      description: "Result monad for Elixir inspired by Rust Result type.",
      package: package(),
      source_url: "https://github.com/linkdd/rustic_result"
    ]
  end

  defp package do
    [
      name: "rustic_result",
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/linkdd/rustic_result"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md": [
          filename: "readme",
          title: "Overview"
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {
        # Documentation
        :ex_doc, "~> 0.25",
        only: :dev,
        runtime: false
      },
      {
        # Static Analysis
        :credo, "~> 1.4",
        only: [:dev, :test],
        runtime: false
      }
    ]
  end
end
