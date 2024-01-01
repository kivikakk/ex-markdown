defmodule Markdown.Renderer do
  defmodule Options do
    defstruct breaks: false
  end

  defmacro __using__(_params) do
    quote do
      def block_code(_opts, code, lang) do
        "<pre><code class=\"language-#{lang}\">#{HtmlEntities.encode(code)}</code></pre>"
      end

      def block_quote(_opts, quote) do
        "<blockquote>#{quote}</blockquote>"
      end

      def block_html(_opts, raw_html) do
        raw_html
      end

      def footnotes(_opts, content) do
        "<div class=\"footnotes\"><hr/><ol>#{content}</ol></div>"
      end

      def footnote_def(_opts, content, number) do
        "<li id=\"fn#{number}\">&nbsp;<a href=\"#fnref#{number}\">&#8617;</a>#{content}</li>"
      end

      def footnote_ref(_opts, number) do
        "<sup id=\"fnref#{number}\"><a href=\"#fn#{number}\">#{number}</a></sup>"
      end

      def header(_opts, text, header_level) do
        "<h#{header_level}>#{text}</h#{header_level}>"
      end

      def hrule(_opts) do
        "<hr/>"
      end

      def list(_opts, contents, list_type, start) do
        if list_type == "bullet" do
          "<ul start=\"#{start}\">#{contents}</ul>"
        else
          "<ol start=\"#{start}\">#{contents}</ol>"
        end
      end

      def list_item(_opts, text, _list_type) do
        "<li>#{text}</li>"
      end

      def paragraph(_opts, text) do
        "<p>#{text}</p>"
      end

      def table(_opts, header, body) do
        "<table><thead>#{header}</thead><tbody>#{body}</tbody></table>"
      end

      def table_row(_opts, content) do
        "<tr>#{content}</tr>"
      end

      def table_cell(_opts, content, alignment, header) do
        cell =
          if header do
            "<th"
          else
            "<td"
          end

        cell =
          if alignment != "" do
            "#{cell} style=\"text-align: #{alignment};\">#{content}"
          else
            "#{cell}>#{content}"
          end

        if header do
          "#{cell}</th>"
        else
          "#{cell}</td>"
        end
      end

      def autolink(_opts, url, link_type) do
        href =
          case link_type do
            "email" ->
              "mailto:#{url}"

            _ ->
              url
          end

        "<a href=\"#{href}\">#{url}</a>"
      end

      def codespan(_opts, code) do
        "<code>#{HtmlEntities.encode(code)}</code>"
      end

      def double_emphasis(_opts, text) do
        "<strong>#{text}</strong>"
      end

      def emphasis(_opts, text) do
        "<em>#{text}</em>"
      end

      def image(_opts, url, title, alt_text) do
        img = "<img src=\"#{url}\""

        img =
          if title != "" do
            img <> " title=\"#{title}\" alt=\""
          else
            img <> " alt=\""
          end

        "#{img}#{alt_text}\"/>"
      end

      def linebreak(_opts) do
        "\n"
      end

      def softbreak(%Options{} = opts) do
        if opts.breaks do "<br>" else " " end
      end

      def link(_opts, url, title, content) do
        a = "<a href=\"#{url}\""

        a =
          if title != "" do
            a <> " title=\"#{title}\">"
          else
            a <> ">"
          end

        "#{a}#{content}</a>"
      end

      def raw_html(_opts, raw_html) do
        raw_html
      end

      def triple_emphasis(_opts, text) do
        "<strong><em>#{text}</em></strong>"
      end

      def strikethrough(_opts, text) do
        "<del>#{text}</del>"
      end

      def superscript(_opts, text) do
        "<sup>#{text}</sup>"
      end

      def underline(_opts, text) do
        "<u>#{text}</u>"
      end

      def highlight(_opts, text) do
        "<mark>#{text}</mark>"
      end

      def quote(_opts, text) do
        "<q>#{text}</q>"
      end

      defoverridable block_code: 3,
                     block_html: 2,
                     block_quote: 2,
                     footnotes: 2,
                     footnote_def: 3,
                     header: 3,
                     hrule: 1,
                     list: 4,
                     list_item: 3,
                     paragraph: 2,
                     table: 3,
                     table_row: 2,
                     table_cell: 4,
                     autolink: 3,
                     codespan: 2,
                     double_emphasis: 2,
                     emphasis: 2,
                     linebreak: 1,
                     softbreak: 1,
                     image: 4,
                     link: 4,
                     raw_html: 2,
                     triple_emphasis: 2,
                     strikethrough: 2,
                     superscript: 2,
                     underline: 2,
                     highlight: 2,
                     quote: 2,
                     footnote_ref: 2
    end
  end
end
