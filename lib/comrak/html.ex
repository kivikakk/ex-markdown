defmodule Comrak.Html do
  alias Comrak.Native
  alias Comrak.Html.Renderer

  defmodule Context do
    defstruct output: "", footnote_ix: 0, data: nil, renderer: Renderer
  end

  def render({_node, _children} = root, renderer \\ Renderer, data \\ %{}) do
    context = render_node(%Context{data: data, renderer: renderer}, root)

    context =
      if context.footnote_ix > 0 do
        write(context, "</ol></section>")
      else
        context
      end

    context.output
  end

  defp clear(%Context{} = context) do
    context
    |> Map.put(:footnote_ix, 0)
    |> Map.put(:output, "")
  end

  defp write(%Context{output: output} = context, text) do
    Map.put(context, :output, output <> text)
  end

  defp render_children_as_text(%Context{} = context, children) do
    Enum.reduce(children, context, fn child, context ->
      render_node_as_text(context, child)
    end)
  end

  defp render_node_as_text(%Context{} = context, {node, children}) do
    case node do
      %Native.Code{code: code} ->
        write(context, code)

      %Native.Text{text: text} ->
        write(context, text)

      %Native.LineBreak{} ->
        write(context, " ")

      %Native.SoftBreak{} ->
        write(context, " ")

      _ ->
        render_children_as_text(context, children)
    end
  end

  defp render_children(%Context{} = context, children) do
    Enum.reduce(children, context, fn child, context ->
      render_node(context, child)
    end)
  end

  defp render_node(%Context{} = context, {node, children}) do
    case node do
      %Native.Document{} ->
        render_children(context, children)

      %Native.BlockQuote{} ->
        tmp = render_children(clear(context), children)
        write(context, context.renderer.block_quote(context.data, tmp.output))

      %Native.List{list: list} ->
        tmp = render_children(clear(context), children)

        write(
          context,
          context.renderer.list(context.data, tmp.output, list.list_type, list.start)
        )

      %Native.Item{list: list} ->
        tmp = render_children_as_text(clear(context), children)
        write(context, context.renderer.list_item(context.data, tmp.output, list.list_type))

      %Native.Heading{heading: heading} ->
        tmp = render_children(clear(context), children)
        write(context, context.renderer.header(context.data, tmp.output, heading.level))

      %Native.CodeBlock{block: block} ->
        lang = Enum.at(String.split(block.info, " "), 0)
        write(context, context.renderer.block_code(context.data, block.literal, lang))

      %Native.HtmlBlock{block: block} ->
        write(context, context.renderer.block_html(context.data, block.literal))

      %Native.ThematicBreak{} ->
        write(context, context.renderer.hrule(context.data))

      %Native.Paragraph{} ->
        tmp = render_children(clear(context), children)
        write(context, context.renderer.paragraph(context.data, tmp.output))

      %Native.Text{text: text} ->
        write(context, HtmlEntities.encode(text))

      %Native.LineBreak{} ->
        write(context, context.renderer.linebreak(context.data))

      %Native.SoftBreak{} ->
        write(context, context.renderer.softbreak(context.data))

      %Native.Code{code: code} ->
        write(context, context.renderer.codespan(context.data, code))

      %Native.HtmlInline{html: html} ->
        write(context, context.renderer.raw_html(context.data, html))

      %Native.Strong{} ->
        tmp = render_children(clear(context), children)
        write(context, context.renderer.double_emphasis(context.data, tmp.output))

      %Native.Emph{} ->
        tmp = render_children(clear(context), children)
        write(context, context.renderer.emphasis(context.data, tmp.output))

      %Native.Strikethrough{} ->
        tmp = render_children(clear(context), children)
        write(context, context.renderer.strikethrough(context.data, tmp.output))

      %Native.Superscript{} ->
        tmp = render_children(clear(context), children)
        write(context, context.renderer.superscript(context.data, tmp.output))

      %Native.Link{link: link} ->
        tmp = render_children(clear(context), children)
        write(context, context.renderer.link(context.data, link.url, link.title, tmp.output))

      %Native.Image{link: link} ->
        tmp = render_children_as_text(clear(context), children)
        write(context, context.renderer.image(context.data, link.url, link.title, tmp.output))

      %Native.Table{alignments: _alignments} ->
        # TODO: speciel render for tables
        context

      %Native.TableRow{header: _header} ->
        context

      %Native.TableCell{} ->
        context

      %Native.FootnoteDefinition{name: _name} ->
        context = Map.put(context, :footnote_ix, context.footnote_ix + 1)
        tmp = render_children_as_text(clear(context), children)

        write(
          context,
          context.renderer.footnote_def(context.data, tmp.output, context.footnote_ix)
        )

      %Native.FootnoteReference{name: name} ->
        write(context, context.renderer.footnote_ref(context.data, name))
    end
  end
end
