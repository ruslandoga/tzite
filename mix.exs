defmodule TzdataSqlite.MixProject do
  use Mix.Project

  def project do
    [
      app: :tzdata_sqlite,
      version: "0.1.0",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {TzdataSqlite.Application, []},
      extra_applications: [:logger]
    ]
  end

  # defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "dev"]
  defp elixirc_paths(_env), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:exqlite, "~> 0.11.2"},
      {:mint, "~> 1.4"},
      {:castore, "~> 0.1.17"},
      {:ecto_sqlite3, "~> 0.7.7"},
      {:rexbug, "~> 1.0", only: :dev}
    ]
  end
end
