defmodule ExActivecampaign.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_activecampaign,
      version: "0.1.2",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/mocks"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ExActivecampaign.Application, [env: Mix.env()]},
      extra_applications: [:logger],
      applications: applications(Mix.env())
    ]
  end

  defp applications(:test), do: applications(:default) ++ [:telemetry, :cowboy, :plug]
  defp applications(_), do: [:httpoison]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:plug_cowboy, "~> 2.0", only: [:test]}
    ]
  end
end
