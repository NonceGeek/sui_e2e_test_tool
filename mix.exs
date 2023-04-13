defmodule MoveE2eTestTool.MixProject do
  use Mix.Project

  def project do
    [
      app: :move_e2e_test_tool,
      version: "0.1.0",
      elixir: "~> 1.14",
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
      {:web3_aptos_ex, "~> 1.0.6"},
      {:binary, "~> 0.0.5"},
      {:nimble_parsec, "~> 1.2"},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
