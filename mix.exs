defmodule Markdown.MixProject do
  use Mix.Project

  def project do
    [
      app: :markdown,
      version: "0.1.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:rustler] ++ Mix.compilers(),
      rustler_crates: rustler_crates()
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
      {:html_entities, "~> 0.4"},
      {:rustler, "~> 0.16"}
    ]
  end

  defp rustler_crates do
    [
      io: [
        path: "native/comrak",
        mode: if(Mix.env() == :prod, do: :release, else: :debug)
      ]
    ]
  end
end
