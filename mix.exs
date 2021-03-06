defmodule Wallet.Mixfile do
  use Mix.Project

  def project do
    [
      app: :elixium_wallet,
      version: "0.1.0",
      build_path: "_build",
      config_path: "config/config.exs",
      deps_path: "deps",
      lockfile: "mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: ["lib"],
      start_permanent: Mix.env == :prod,
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
    [{:elixium_core, "~> 0.2"}]
  end
end
