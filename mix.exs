defmodule Markdown.MixProject do
  use Mix.Project

  def project do
    [
      app: :markdown,
      version: "0.1.0",
      elixir: "~> 1.4",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      compilers: [:rustler] ++ Mix.compilers(),
      rustler_crates: rustler_crates(),
      source_url: "https://gitlab.com/nathanfaucett/ex-markdown"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "markdown nif render for comrak markdown parser in rust"
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Nathan Faucett"],
      licenses: ["MIT"],
      links: %{"Gitlab" => "https://gitlab.com/nathanfaucett/ex-markdown"}
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
