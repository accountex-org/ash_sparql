defmodule AshSparql.MixProject do
  use Mix.Project

  def project do
    [
      app: :ash_sparql,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :dev,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ash, "~> 3.5.9"},
      {:spark, "~> 2.2.54"},
      {:mint, "~> 1.5"},
      {:mint_web_socket, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.30", only: [:dev, :test], runtime: false},
      {:igniter, "~> 0.5", only: [:dev, :test]},
      {:bypass, "~> 2.1", only: :test},
      {:mox, "~> 1.1", only: :test}
    ]
  end
end