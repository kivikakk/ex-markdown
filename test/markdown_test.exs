defmodule MarkdownTest do
  use ExUnit.Case
  doctest Markdown

  defmodule TestRenderer do
    use Markdown.Renderer

    def block_code(_opts, code, lang) do
      "<pre><code class=\"#{lang}\">#{HtmlEntities.encode(code)}</code></pre>"
    end
  end

  def html(md, opts, renderer, expected) do
    assert expected == Markdown.to_html(md, opts, renderer)
  end

  def html2(md, opts, native, html) do
    assert html(md, opts, nil, native)
    assert html(md, opts, Markdown.HtmlRenderer, html)
  end

  test "parse markdown into ast" do
    assert Markdown.to_ast("Hello, world!") ==
             {%Markdown.Native.Document{},
              [
                {%Markdown.Native.Paragraph{},
                 [{%Markdown.Native.Text{text: "Hello, world!"}, []}]}
              ]}
  end

  test "basic html" do
    html2(
      Enum.join(
        [
          "My **document**.",
          "",
          "It's mine.",
          "> Yes.",
          "## Hi!",
          "Okay.",
        ],
        "\n"
      ),
      %{},
      Enum.join(
        [
          "<p>My <strong>document</strong>.</p>\n",
          "<p>It's mine.</p>\n",
          "<blockquote>\n",
          "<p>Yes.</p>\n",
          "</blockquote>\n",
          "<h2>Hi!</h2>\n",
          "<p>Okay.</p>\n",
        ],
        ""
      ),
      Enum.join(
        [
          "<p>My <strong>document</strong>.</p>",
          "<p>It&#39;s mine.</p>",
          "<blockquote>",
          "<p>Yes.</p>",
          "</blockquote>",
          "<h2>Hi!</h2>",
          "<p>Okay.</p>",
        ],
        ""
      )
    )
  end

  test "codefence html" do
    html(
      Enum.join(
        [
          "``` rust yum",
          "fn main<'a>();",
          "```",
        ],
        "\n"
      ),
      %{},
      TestRenderer,
      Enum.join(
        [
          "<pre><code class=\"rust\">fn main&lt;&#39;a&gt;();\n",
          "</code></pre>",
        ],
        ""
      )
    )
  end

  test "list html" do
    html2(
      Enum.join(
        [
          "2. Hello.",
          "3. Hi.",
        ],
        "\n"
      ),
      %{},
      Enum.join(
        [
          "<ol start=\"2\">\n",
          "<li>Hello.</li>\n",
          "<li>Hi.</li>\n",
          "</ol>\n",
        ],
        ""
      ),
      Enum.join(
        [
          "<ol start=\"2\">",
          # XXX(ashe): no tightness distinction on lists in the Elixir renderer.
          "<li><p>Hello.</p></li>",
          "<li><p>Hi.</p></li>",
          "</ol>",
        ],
        ""
      )
    )
  end

  test "thematic breaks html" do
    html2(
      Enum.join(
        [
          "Hi",
          "==",
          "",
          "Ok",
          "-----",
        ],
        "\n"
      ),
      %{},
      Enum.join(
        [
          "<h1>Hi</h1>\n",
          "<h2>Ok</h2>\n",
        ],
        ""
      ),
      Enum.join(
        [
          "<h1>Hi</h1>",
          "<h2>Ok</h2>",
        ],
        ""
      )
    )
  end

  test "html block 1 html" do
    html2(
      Enum.join(
        [
          "<script>",
          "*ok* </script> *ok*",
          "",
          "*ok*",
          "",
          "*ok*",
          "",
          "<pre x>",
          "*ok*",
          "</style>",
          "*ok*",
          "<style>",
          "*ok*",
          "</style>",
          "",
          "*ok*",
        ],
        "\n"
      ),
      %{unsafe_: true},
      Enum.join(
        [
          "<script>\n",
          "*ok* </script> *ok*\n",
          "<p><em>ok</em></p>\n",
          "<p><em>ok</em></p>\n",
          "<pre x>\n",
          "*ok*\n",
          "</style>\n",
          "<p><em>ok</em></p>\n",
          "<style>\n",
          "*ok*\n",
          "</style>\n",
          "<p><em>ok</em></p>\n",
        ],
        ""
      ),
      Enum.join(
        [
          "<script>\n",
          "*ok* </script> *ok*\n",
          "<p><em>ok</em></p>",
          "<p><em>ok</em></p>",
          "<pre x>\n",
          "*ok*\n",
          "</style>\n",
          "<p><em>ok</em></p>",
          "<style>\n",
          "*ok*\n",
          "</style>\n",
          "<p><em>ok</em></p>",
        ],
        ""
      )
    )
  end

  test "html block 2 html" do
    html2(
      Enum.join(
        [
          "   <!-- abc",
          "",
          "ok --> *hi*",
          "*hi*",
        ],
        "\n"
      ),
      %{unsafe_: true},
      Enum.join(
        [
          "   <!-- abc\n",
          "\n",
          "ok --> *hi*\n",
          "<p><em>hi</em></p>\n",
        ],
        ""
      ),
      Enum.join(
        [
          "   <!-- abc\n",
          "\n",
          "ok --> *hi*\n",
          "<p><em>hi</em></p>",
        ],
        ""
      )
    )
  end

  test "html block 3 html" do
    html2(
      Enum.join(
        [
          " <? o",
          "k ?> *a*",
          "*a*",
        ],
        "\n"
      ),
      %{unsafe_: true},
      Enum.join(
        [
          " <? o\n",
          "k ?> *a*\n",
          "<p><em>a</em></p>\n",
        ],
        ""
      ),
      Enum.join(
        [
          " <? o\n",
          "k ?> *a*\n",
          "<p><em>a</em></p>",
        ],
        ""
      )
    )
  end

  test "html block 4 html" do
    html2(
      Enum.join(
        [
          "<!X >",
          "ok",
          "<!X",
          "um > h",
          "ok",
        ],
        "\n"
      ),
      %{unsafe_: true},
      Enum.join(
        [
          "<!X >\n",
          "<p>ok</p>\n",
          "<!X\n",
          "um > h\n",
          "<p>ok</p>\n",
        ],
        ""
      ),
      Enum.join(
        [
          "<!X >\n",
          "<p>ok</p>",
          "<!X\n",
          "um > h\n",
          "<p>ok</p>",
        ],
        ""
      )
    )
  end

  test "html block 5 html" do
    html2(
      Enum.join(
        [
          "<![CDATA[",
          "",
          "hm >",
          "*ok*",
          "]]> *ok*",
          "*ok*\n",
        ],
        "\n"
      ),
      %{unsafe_: true},
      Enum.join(
        [
          "<![CDATA[\n",
          "\n",
          "hm >\n",
          "*ok*\n",
          "]]> *ok*\n",
          "<p><em>ok</em></p>\n",
        ],
        ""
      ),
      Enum.join(
        [
          "<![CDATA[\n",
          "\n",
          "hm >\n",
          "*ok*\n",
          "]]> *ok*\n",
          "<p><em>ok</em></p>",
        ],
        ""
      )
    )
  end

  test "html block 6 html" do
    html2(
      Enum.join(
        [
          " </table>",
          "*x*",
          "",
          "ok",
          "",
          "<li",
          "*x*",
        ],
        "\n"
      ),
      %{unsafe_: true},
      Enum.join(
        [
          " </table>\n",
          "*x*\n",
          "<p>ok</p>\n",
          "<li\n",
          "*x*\n",
        ],
        ""
      ),
      Enum.join(
        [
          " </table>\n",
          "*x*\n",
          "<p>ok</p>",
          "<li\n",
          "*x*\n",
        ],
        ""
      )
    )
  end

  test "html block 7 html" do
    html2(
      Enum.join(
        [
          "<a b >",
          "ok",
          "",
          "<a b=>",
          "ok",
          "",
          "<a b",
          "<a b> c",
          "ok\n",
        ],
        "\n"
      ),
      %{unsafe_: true},
      Enum.join(
        [
          "<a b >\n",
          "ok\n",
          "<p>&lt;a b=&gt;\n",
          "ok</p>\n",
          "<p>&lt;a b\n",
          "<a b> c\n",
          "ok</p>\n",
        ],
        ""
      ),
      Enum.join(
        [
          "<a b >\n",
          "ok\n",
          "<p>&lt;a b=&gt; ",
          "ok</p>",
          "<p>&lt;a b ",
          "<a b> c ",
          "ok</p>",
        ],
        ""
      )
    )
  end

  test "links" do
    html2(
      Enum.join(
        [
          "Where are you [going](https://microsoft.com (today))?",
          "",
          "[Where am I?](/here)",
        ],
        "\n"
      ),
      %{},
      Enum.join(
        [
          "<p>Where are you <a href=\"https://microsoft.com\" title=\"today\">going</a>?</p>\n",
          "<p><a href=\"/here\">Where am I?</a></p>\n",
        ],
        ""
      ),
      Enum.join(
        [
          "<p>Where are you <a href=\"https://microsoft.com\" title=\"today\">going</a>?</p>",
          "<p><a href=\"/here\">Where am I?</a></p>",
        ],
        ""
      )
    )
  end

  test "images" do
    html2(
      Enum.join(
        [
          "I am ![eating [things](/url)](http://i.imgur.com/QqK1vq7.png).\n",
        ],
        "\n"
      ),
      %{},
      Enum.join(
        [
          "<p>I am <img src=\"http://i.imgur.com/QqK1vq7.png\" alt=\"eating things\" />.</p>\n",
        ],
        ""
      ),
      Enum.join(
        [
          "<p>I am <img src=\"http://i.imgur.com/QqK1vq7.png\" alt=\"eating things\"/>.</p>",
        ],
        ""
      )
    )
  end

  test "tables" do
    html2(
      Enum.join(
        [
          "| a | b |",
          "|---|:-:|",
          "| c | d |",
        ],
        "\n"
      ),
      %{table: true},
      Enum.join(
        [
          "<table>\n",
          "<thead>\n",
          "<tr>\n",
          "<th>a</th>\n",
          "<th align=\"center\">b</th>\n",
          "</tr>\n",
          "</thead>\n",
          "<tbody>\n",
          "<tr>\n",
          "<td>c</td>\n",
          "<td align=\"center\">d</td>\n",
          "</tr>\n",
          "</tbody>\n",
          "</table>\n",
        ],
        ""
      ),
      Enum.join(
        [
          "<table>",
          "<thead>",
          "<tr>",
          "<th>a</th>",
          "<th style=\"text-align: center;\">b</th>",
          "</tr>",
          "</thead>",
          "<tbody>",
          "<tr>",
          "<td>c</td>",
          "<td style=\"text-align: center;\">d</td>",
          "</tr></tbody></table>",
        ],
        ""
      )
    )
  end

  test "hardbreaks off" do
    html2(
      Enum.join(
        [
          "Hello,",
          "world.",
        ],
        "\n"
      ),
      %{},
      Enum.join(
        [
          "<p>Hello,\nworld.</p>\n",
        ],
        ""
      ),
      Enum.join(
        [
          "<p>Hello, world.</p>",
        ],
        ""
      )
    )
  end

  test "hardbreaks on" do
    html2(
      Enum.join(
        [
          "Hello,",
          "world.",
        ],
        "\n"
      ),
      %{hardbreaks: true},
      Enum.join(
        [
          "<p>Hello,<br />\n",
          "world.</p>\n",
        ],
        ""
      ),
      Enum.join(
        [
          "<p>Hello,<br>",
          "world.</p>",
        ],
        ""
      )
    )
  end

  test "autolink on" do
    html2(
      Enum.join(
        [
          "Hello abc@def.com friend",
        ],
        "\n"
      ),
      %{autolink: true},
      Enum.join(
        [
          "<p>Hello <a href=\"mailto:abc@def.com\">abc@def.com</a> friend</p>\n",
        ],
        ""
      ),
      Enum.join(
        [
          "<p>Hello <a href=\"mailto:abc@def.com\">abc@def.com</a> friend</p>",
        ],
        ""
      )
    )
  end

  test "autolink off" do
    html2(
      Enum.join(
        [
          "Hello abc@def.com friend",
        ],
        "\n"
      ),
      %{autolink: false},
      Enum.join(
        [
          "<p>Hello abc@def.com friend</p>\n",
        ],
        ""
      ),
      Enum.join(
        [
          "<p>Hello abc@def.com friend</p>",
        ],
        ""
      )
    )
  end
end
