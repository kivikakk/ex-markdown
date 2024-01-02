defmodule Markdown.Native do
  use Rustler, otp_app: :markdown,
               crate: :comrak_rustler,
               mode: if(Mix.env() == :prod, do: :release, else: :debug),
               skip_compilation?: System.get_env("MARKDOWN_NATIVE_SKIP_COMPILATION") != nil

  defmodule NodeList do
    defstruct list_type: "",
              start: 0,
              delimiter: "",
              bullet_char: "",
              tight: false
  end

  defmodule NodeCodeBlock do
    defstruct fenced: false,
              fence_char: "",
              fence_length: 0,
              info: "",
              literal: ""
  end

  defmodule NodeHtmlBlock do
    defstruct literal: ""
  end

  defmodule NodeHeading do
    defstruct level: 0, setext: false
  end

  defmodule NodeLink do
    defstruct url: "", title: ""
  end

  defmodule Document do
    defstruct []
  end

  defmodule BlockQuote do
    defstruct []
  end

  defmodule List do
    defstruct list: nil
  end

  defmodule Item do
    defstruct list: nil
  end

  defmodule CodeBlock do
    defstruct block: nil
  end

  defmodule HtmlBlock do
    defstruct block: nil
  end

  defmodule Paragraph do
    defstruct []
  end

  defmodule Heading do
    defstruct heading: nil
  end

  defmodule ThematicBreak do
    defstruct []
  end

  defmodule FootnoteDefinition do
    defstruct name: ""
  end

  defmodule Table do
    defstruct alignments: []
  end

  defmodule TableRow do
    defstruct header: false
  end

  defmodule TableCell do
    defstruct []
  end

  defmodule Text do
    defstruct text: ""
  end

  defmodule SoftBreak do
    defstruct []
  end

  defmodule LineBreak do
    defstruct []
  end

  defmodule Code do
    defstruct code: ""
  end

  defmodule HtmlInline do
    defstruct html: ""
  end

  defmodule Emph do
    defstruct []
  end

  defmodule Strong do
    defstruct []
  end

  defmodule Strikethrough do
    defstruct []
  end

  defmodule Superscript do
    defstruct []
  end

  defmodule Link do
    defstruct link: nil
  end

  defmodule Image do
    defstruct link: nil
  end

  defmodule FootnoteReference do
    defstruct name: ""
  end

  def parse(_text), do: :erlang.nif_error(:nif_not_loaded)
  def html(_ast), do: :erlang.nif_error(:nif_not_loaded)
end
