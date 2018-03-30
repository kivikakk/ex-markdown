defmodule ComrakTest do
  use ExUnit.Case
  doctest Comrak

  defmodule TestRenderer do
    use Comrak.Html.Base

    def block_code(_data, code, lang) do
      "<pre><code class=\"#{lang}\">#{HtmlEntities.encode(code)}</code></pre>"
    end
  end

  def html(text, output, renderer \\ Comrak.Html.Renderer) do
    ast = Comrak.Native.parse(text)
    assert Comrak.Html.render(ast, renderer) == output
  end

  test "parse markdown into ast" do
    assert Comrak.Native.parse("Hello, world!") ==
             {%Comrak.Native.Document{},
              [
                {%Comrak.Native.Paragraph{}, [{%Comrak.Native.Text{text: "Hello, world!"}, []}]}
              ]}
  end

  test "basic html" do
    html(
      Enum.join(
        [
          "My **document**.",
          "",
          "It's mine.",
          "> Yes.",
          "## Hi!",
          "Okay."
        ],
        "\n"
      ),
      Enum.join(
        [
          "<p>My <strong>document</strong>.</p>",
          "<p>It&apos;s mine.</p>",
          "<blockquote>",
          "<p>Yes.</p>",
          "</blockquote>",
          "<h2>Hi!</h2>",
          "<p>Okay.</p>"
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
          "```"
        ],
        "\n"
      ),
      Enum.join(
        [
          "<pre><code class=\"rust\">fn main&lt;&apos;a&gt;();\n",
          "</code></pre>"
        ],
        ""
      ),
      TestRenderer
    )
  end

  test "list html" do
    html(
      Enum.join(
        [
          "2. Hello.",
          "3. Hi."
        ],
        "\n"
      ),
      Enum.join(
        [
          "<ol start=\"2\">",
          "<li>Hello.</li>",
          "<li>Hi.</li>",
          "</ol>"
        ],
        ""
      )
    )
  end

  test "thematic breaks html" do
    html(
      Enum.join(
        [
          "Hi",
          "==",
          "",
          "Ok",
          "-----"
        ],
        "\n"
      ),
      Enum.join(
        [
          "<h1>Hi</h1>",
          "<h2>Ok</h2>"
        ],
        ""
      )
    )
  end

  test "html block 1 html" do
    html(
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
          "*ok*"
        ],
        "\n"
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
          "<p><em>ok</em></p>"
        ],
        ""
      )
    )
  end

  test "html block 2 html" do
    html(
      Enum.join(
        [
          "   <!-- abc",
          "",
          "ok --> *hi*",
          "*hi*"
        ],
        "\n"
      ),
      Enum.join(
        [
          "   <!-- abc\n",
          "\n",
          "ok --> *hi*\n",
          "<p><em>hi</em></p>"
        ],
        ""
      )
    )
  end

  test "html block 3 html" do
    html(
      Enum.join(
        [
          " <? o",
          "k ?> *a*",
          "*a*"
        ],
        "\n"
      ),
      Enum.join(
        [
          " <? o\n",
          "k ?> *a*\n",
          "<p><em>a</em></p>"
        ],
        ""
      )
    )
  end

  test "html block 4 html" do
    html(
      Enum.join(
        [
          "<!X >",
          "ok",
          "<!X",
          "um > h",
          "ok"
        ],
        "\n"
      ),
      Enum.join(
        [
          "<!X >\n",
          "<p>ok</p>",
          "<!X\n",
          "um > h\n",
          "<p>ok</p>"
        ],
        ""
      )
    )
  end

  test "html block 5 html" do
    html(
      Enum.join(
        [
          "<![CDATA[",
          "",
          "hm >",
          "*ok*",
          "]]> *ok*",
          "*ok*\n"
        ],
        "\n"
      ),
      Enum.join(
        [
          "<![CDATA[\n",
          "\n",
          "hm >\n",
          "*ok*\n",
          "]]> *ok*\n",
          "<p><em>ok</em></p>"
        ],
        ""
      )
    )
  end

  test "html block 6 html" do
    html(
      Enum.join(
        [
          " </table>",
          "*x*",
          "",
          "ok",
          "",
          "<li",
          "*x*"
        ],
        "\n"
      ),
      Enum.join(
        [
          " </table>\n",
          "*x*\n",
          "<p>ok</p>",
          "<li\n",
          "*x*\n"
        ],
        ""
      )
    )
  end

  test "html block 7 html" do
    html(
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
          "ok\n"
        ],
        "\n"
      ),
      Enum.join(
        [
          "<a b >\n",
          "ok\n",
          "<p>&lt;a b=&gt; ",
          "ok</p>",
          "<p>&lt;a b ",
          "<a b> c ",
          "ok</p>"
        ],
        ""
      )
    )
  end

  test "links" do
    html(
      Enum.join(
        [
          "Where are you [going](https://microsoft.com (today))?",
          "",
          "[Where am I?](/here)"
        ],
        "\n"
      ),
      Enum.join(
        [
          "<p>Where are you <a href=\"https://microsoft.com\" title=\"today\">going</a>?</p>",
          "<p><a href=\"/here\">Where am I?</a></p>"
        ],
        ""
      )
    )
  end

  test "images" do
    html(
      Enum.join(
        [
          "I am ![eating [things](/url)](http://i.imgur.com/QqK1vq7.png).\n"
        ],
        "\n"
      ),
      Enum.join(
        [
          "<p>I am <img src=\"http://i.imgur.com/QqK1vq7.png\" alt=\"eating things\"/>.</p>"
        ],
        ""
      )
    )
  end
end
