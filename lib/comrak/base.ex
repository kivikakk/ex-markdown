defmodule Comrak.Html.Base do
  defmacro __using__(_params) do
    quote do
      def block_code(_data, code, lang) do
        "<pre><code class=\"language-#{lang}\">#{HtmlEntities.encode(code)}</code></pre>"
      end

      def block_quote(_data, quote) do
        "<blockquote>#{quote}</blockquote>"
      end

      def block_html(_data, raw_html) do
        raw_html
      end

      def footnotes(_data, content) do
        "<div class=\"footnotes\"><hr/><ol>#{content}</ol></div>"
      end

      def footnote_def(_data, content, number) do
        "<li id=\"fn#{number}\">&nbsp;<a href=\"#fnref#{number}\">&#8617;</a>#{content}</li>"
      end

      def header(_data, text, header_level) do
        "<h#{header_level}>#{text}</h#{header_level}>"
      end

      def hrule(_data) do
        "<hr/>"
      end

      def list(_data, contents, list_type, start) do
        if list_type == "bullet" do
          "<ul start=\"#{start}\">#{contents}</ul>"
        else
          "<ol start=\"#{start}\">#{contents}</ol>"
        end
      end

      def list_item(_data, text, _list_type) do
        "<li>#{text}</li>"
      end

      def paragraph(_data, text) do
        "<p>#{text}</p>"
      end

      def table(_data, header, body) do
        "<table><thead>#{header}</thead><tbody>#{body}</tbody></table>"
      end

      def table_row(_data, content) do
        "<tr>#{content}</tr>"
      end

      def table_cell(_data, content, alignment) do
        "<td style=\"text-align: #{alignment}\">>#{content}</td>"
      end

      def autolink(_data, url, link_type) do
        href =
          case link_type do
            "email" ->
              "mailto:#{url}"

            _ ->
              url
          end

        "<a href=\"#{href}\">#{url}</a>"
      end

      def codespan(_data, code) do
        "<code>#{HtmlEntities.encode(code)}</code>"
      end

      def double_emphasis(_data, text) do
        "<strong>#{text}</strong>"
      end

      def emphasis(_data, text) do
        "<em>#{text}</em>"
      end

      def image(_data, url, title, alt_text) do
        img = "<img src=\"#{url}\""

        img =
          if title != "" do
            img <> " title=\"#{title}\" alt=\""
          else
            img <> " alt=\""
          end

        "#{img}#{alt_text}\"/>"
      end

      def linebreak(_data) do
        "\n"
      end

      def softbreak(_data) do
        " "
      end

      def link(_data, url, title, content) do
        a = "<a href=\"#{url}\""

        a =
          if title != "" do
            a <> " title=\"#{title}\">"
          else
            a <> ">"
          end

        "#{a}#{content}</a>"
      end

      def raw_html(_data, raw_html) do
        raw_html
      end

      def triple_emphasis(_data, text) do
        "<strong><em>#{text}</em></strong>"
      end

      def strikethrough(_data, text) do
        "<del>#{text}</del>"
      end

      def superscript(_data, text) do
        "<sup>#{text}</sup>"
      end

      def underline(_data, text) do
        "<u>#{text}</u>"
      end

      def highlight(_data, text) do
        "<mark>#{text}</mark>"
      end

      def quote(_data, text) do
        "<q>#{text}</q>"
      end

      def footnote_ref(_data, number) do
        "<sup id=\"fnref#{number}\"><a href=\"#fn#{number}\">#{number}</a></sup>"
      end

      defoverridable block_code: 3, block_html: 2, block_quote: 2
    end
  end
end
