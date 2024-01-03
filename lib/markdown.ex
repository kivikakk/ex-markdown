defmodule Markdown do
  def to_ast(md, opts \\ %{})
  def to_ast(md, opts) when is_binary(md) do
    Markdown.Native.markdown_to_ast(md, opts(opts))
  end
  def to_ast(md, _) do md end

  def to_html(md, opts \\ %{}, renderer \\ nil) do
    if renderer == nil and is_binary(md) do
      Markdown.Native.markdown_to_html(md, opts(opts))
    else
      Markdown.Render.render(to_ast(md, opts(opts)), opts(opts), renderer || Markdown.HtmlRenderer)
    end
  end

  defp opts(opts) do
    %Markdown.Renderer.Options{}
    |> Map.merge(opts)
  end
end
