> [!WARNING]
> This README is currently out-of-date, but this fork isn't!

---

# Markdown

markdown renderer for [comrak](https://github.com/kivikakk/comrak) markdown parser

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `markdown` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:markdown, "~> 0.1"}
  ]
end
```

## Usage

```elixir
# (markdown[, Renderer \\ Markdown.HtmlRenderer][, data \\ %{}])
Markdown.render("# Hello, world")
```

## Custom Renderers

```elixir
defmodule MyModule.CustomRenderer do
  use Markdown.Renderer

  def block_code(_data, code, lang) do
  	"<pre><code class=\"language-#{lang} #{lang}\">#{HtmlEntities.encode(code)}</code></pre>"
  end
end
```

## Overrides

### Block

```
block_code(data, code, lang)
block_quote(data, quote)
block_html(data, raw_html)
footnotes(data, content)
footnote_def(data, content, number)
footnote_ref(data, number)
header(data, text, header_level)
hrule(data)
list(data, contents, list_type, start)
list_item(data, text, list_type)
paragraph(data, text)
table(data, header, body)
table_row(data, content)
table_cell(data, content, alignment, header)
```

### Inline

```
codespan(data, code)
double_emphasis(data, text)
emphasis(data, text)
image(data, url, title, alt_text)
linebreak(data)
softbreak(data)
link(data, url, title, content)
raw_html(data, raw_html)
triple_emphasis(data, text)
strikethrough(data, text)
superscript(data, text)
underline(data, text)
highlight(data, text)
quote(data, text)
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/markdown](https://hexdocs.pm/markdown).
