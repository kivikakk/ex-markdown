# Comrak

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `comrak` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:comrak, "~> 0.1.0"}
  ]
end
```

```elixir
defmodule Comrak.HtmlRenderer do
  use Comrak.Renderer

  def block_code(_data, code, lang) do
  	"<pre><code class=\"language-#{lang}\">#{HtmlEntities.encode(code)}</code></pre>"
  end
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/comrak](https://hexdocs.pm/comrak).
