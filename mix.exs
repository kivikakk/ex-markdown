defmodule Markdown.MixProject do
  use Mix.Project

  def project do
    [
      app: :markdown,
      version: "0.1.1",
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
    "markdown renderer for comrak markdown parser"
  end

  defp package() do
    [
      files: ["lib", "native", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Nathan Faucett"],
      licenses: ["MIT"],
      links: %{"Gitlab" => "https://gitlab.com/nathanfaucett/ex-markdown"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:html_entities, "~> 0.4"},
      {:rustler, "~> 0.16"},
      {:ex_doc, ">= 0.0.0", only: :dev}
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
