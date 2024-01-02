defmodule Markdown do
  def parse(text) do
    Markdown.Native.parse(text)
  end

  def render(text, renderer \\ Markdown.HtmlRenderer, opts \\ %{}) do
    Markdown.Render.render(parse(text), renderer, opts)
  end
end
