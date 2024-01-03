defmodule Markdown.Render do
  alias Markdown.Native
  alias Markdown.Renderer

  defmodule Context do
    defstruct output: "", footnote_ix: 0, opts: nil, renderer: nil
  end

  def render({_node, _children} = root, opts = %{}, renderer) do
    context = render_node(%Context{opts: %Renderer.Options{} |> Map.merge(opts), renderer: renderer}, root)
    context.output
  end

  defp clear(%Context{} = context) do
    context
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
        kids = render_children(clear(context), children)
        write(context, context.renderer.block_quote(context.opts, kids.output))

      %Native.List{list: list} ->
        kids = render_children(clear(context), children)

        write(
          context,
          context.renderer.list(context.opts, kids.output, list.list_type, list.start)
        )

      %Native.Item{list: list} ->
        # XXX(ashe): we don't do any tightness distinctions on lists.
        kids = render_children(clear(context), children)
        write(context, context.renderer.list_item(context.opts, kids.output, list.list_type))

      %Native.Heading{heading: heading} ->
        kids = render_children(clear(context), children)
        write(context, context.renderer.header(context.opts, kids.output, heading.level))

      %Native.CodeBlock{block: block} ->
        lang = Enum.at(String.split(block.info, " "), 0)
        write(context, context.renderer.block_code(context.opts, block.literal, lang))

      %Native.HtmlBlock{block: block} ->
        write(context, context.renderer.block_html(context.opts, block.literal))

      %Native.ThematicBreak{} ->
        write(context, context.renderer.hrule(context.opts))

      %Native.Paragraph{} ->
        kids = render_children(clear(context), children)
        write(context, context.renderer.paragraph(context.opts, kids.output))

      %Native.Text{text: text} ->
        write(context, HtmlEntities.encode(text))

      %Native.LineBreak{} ->
        write(context, context.renderer.linebreak(context.opts))

      %Native.SoftBreak{} ->
        write(context, context.renderer.softbreak(context.opts))

      %Native.Code{code: code} ->
        write(context, context.renderer.codespan(context.opts, code))

      %Native.HtmlInline{html: html} ->
        write(context, context.renderer.raw_html(context.opts, html))

      %Native.Strong{} ->
        kids = render_children(clear(context), children)
        write(context, context.renderer.double_emphasis(context.opts, kids.output))

      %Native.Emph{} ->
        kids = render_children(clear(context), children)
        write(context, context.renderer.emphasis(context.opts, kids.output))

      %Native.Strikethrough{} ->
        kids = render_children(clear(context), children)
        write(context, context.renderer.strikethrough(context.opts, kids.output))

      %Native.Superscript{} ->
        kids = render_children(clear(context), children)
        write(context, context.renderer.superscript(context.opts, kids.output))

      %Native.Link{link: link} ->
        kids = render_children(clear(context), children)
        write(context, context.renderer.link(context.opts, link.url, link.title, kids.output))

      %Native.Image{link: link} ->
        kids = render_children_as_text(clear(context), children)
        write(context, context.renderer.image(context.opts, link.url, link.title, kids.output))

      %Native.Table{alignments: alignments} ->
        render_table_node(context, alignments, children)

      %Native.TableRow{header: _header} ->
        context

      %Native.TableCell{} ->
        context

      %Native.FootnoteDefinition{name: _name} ->
        context = Map.put(context, :footnote_ix, context.footnote_ix + 1)
        kids = render_children(clear(context), children)

        write(
          context,
          context.renderer.footnote_def(context.opts, kids.output, context.footnote_ix)
        )

      %Native.FootnoteReference{name: name} ->
        write(context, context.renderer.footnote_ref(context.opts, name))

      _ ->
        context
    end
  end

  defp render_table_node(%Context{} = context, alignments, children) do
    {header_context, body_context} =
      Enum.reduce(children, {clear(context), clear(context)}, fn {child_node, child_children},
                                                                 {header_context, body_context} ->
        case child_node do
          %Native.TableRow{header: header} ->
            if header do
              header_context =
                render_table_row_node(
                  clear(context),
                  alignments,
                  child_children,
                  header
                )

              {header_context, body_context}
            else
              body_context =
                render_table_row_node(
                  clear(context),
                  alignments,
                  child_children,
                  header
                )

              {header_context, body_context}
            end

          _ ->
            context
        end
      end)

    write(
      context,
      context.renderer.table(context.opts, header_context.output, body_context.output)
    )
  end

  defp render_table_row_node(%Context{} = context, alignments, children, header) do
    kids =
      Enum.reduce(Enum.with_index(children), clear(context), fn {{child_node, child_children},
                                                                 index},
                                                                context ->
        case child_node do
          %Native.TableCell{} ->
            alignment = Enum.at(alignments, index, "")
            kids = render_children(clear(context), child_children)

            write(
              context,
              context.renderer.table_cell(context.opts, kids.output, alignment, header)
            )

          _ ->
            context
        end
      end)

    write(
      context,
      context.renderer.table_row(context.opts, kids.output)
    )
  end
end
