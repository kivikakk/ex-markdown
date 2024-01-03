defmodule Markdown do
  def parse(text, opts \\ %{}) do
    Markdown.Native.parse(text, %Markdown.Renderer.Options{} |> Map.merge(opts))
  end

  def render(text, opts \\ %{}, renderer \\ Markdown.HtmlRenderer) do
    Markdown.Render.render(parse(text, opts), opts, renderer)
  end
end
