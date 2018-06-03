defmodule Exekiel.MixProject do
  use Mix.Project

  def project do
    [
      app: :exekiel,
      version: "0.1.0",
      elixir: "~> 1.6.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Exekiel, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 0.9", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      check: [
        "format --check-formatted mix.exs \"lib/**/*.{ex,exs}\" \"test/**/*.{ex,exs}\"",
        "credo",
        "dialyzer --halt-exit-status"
      ],
      format: ["format mix.exs \"lib/**/*.{ex,exs}\" \"test/**/*.{ex,exs}\""]
    ]
  end
end
