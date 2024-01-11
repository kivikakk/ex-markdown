defmodule Markdown.MixProject do
  use Mix.Project

  def project do
    [
      app: :markdown,
      version: "0.1.5",
      elixir: "~> 1.4",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
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
    """
    #{File.read!(Path.join(File.cwd!(), "README.md"))}
    """
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
      {:html_entities, "~> 0.5"},
      {:rustler, "~> 0.30"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
