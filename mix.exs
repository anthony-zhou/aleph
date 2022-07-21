defmodule Aleph.MixProject do
  use Mix.Project

  def project do
    [
      app: :aleph,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:merkle_tree, "~> 1.6.0"},
      {:jason, "~> 1.3"}
    ]
  end
end
