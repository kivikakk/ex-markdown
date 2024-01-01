defmodule Markdown do
  def parse(text) do
    Markdown.Native.parse(text)
  end

  def render(text, renderer \\ Markdown.HtmlRenderer, opts \\ %Markdown.Renderer.Options{}) do
    Markdown.Render.render(parse(text), renderer, opts)
  end
end
