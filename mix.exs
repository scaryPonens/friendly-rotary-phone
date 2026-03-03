defmodule MlLab.MixProject do
  use Mix.Project

  def project do
    [
      app: :ml_lab,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {MlLab.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Numerical computing
      {:nx, "~> 0.6"},
      {:exla, "~> 0.6"},

      # Dataframes
      {:explorer, "~> 0.7"},

      # Interactive notebooks
      {:kino, "~> 0.11"},

      # Visualization
      {:vega_lite, "~> 0.1"}
    ]
  end
end
