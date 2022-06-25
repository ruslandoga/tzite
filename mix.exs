defmodule TzdataSqlite.MixProject do
  use Mix.Project

  def project do
    [
      app: :tzdata_sqlite,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
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
      {:exqlite, "~> 0.11.2"},
      {:mint, "~> 1.4"},
      {:castore, "~> 0.1.17"}
    ]
  end
end
