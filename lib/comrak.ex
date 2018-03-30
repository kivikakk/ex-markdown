defmodule Comrak do
  def parse(text) do
    Comrak.Native.parse(text)
  end

  def render(text, renderer \\ Comrak.HtmlRenderer, data \\ %{}) do
    Comrak.Render.render(parse(text), renderer, data)
  end
end
