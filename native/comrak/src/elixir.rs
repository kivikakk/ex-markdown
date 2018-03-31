use comrak::nodes::{self, AstNode, NodeValue};
use comrak::{parse_document, ComrakOptions};
use rustler::{NifEncoder, NifEnv, NifResult, NifTerm};
use typed_arena::Arena;

rustler_export_nifs! {
    "Elixir.Markdown.Native",
    [("parse", 1, parse)],
    None
}

macro_rules! nifs_structs {
    ($($name:tt $struct:item)*) => {$(
        #[derive(NifStruct)]
        #[module = $name]
        $struct
    )*}
}

nifs_structs! {
    "Markdown.Native.NodeList" pub struct NodeList {
        pub list_type: String,
        pub start: usize,
        pub delimiter: String,
        pub bullet_char: String,
        pub tight: bool,
    }
    "Markdown.Native.NodeCodeBlock" pub struct NodeCodeBlock {
        pub fenced: bool,
        pub fence_char: String,
        pub fence_length: usize,
        pub info: String,
        pub literal: String,
    }
    "Markdown.Native.NodeHtmlBlock" pub struct NodeHtmlBlock { pub literal: String }
    "Markdown.Native.NodeHeading" pub struct NodeHeading { pub level: u32, pub setext: bool }
    "Markdown.Native.NodeLink" pub struct NodeLink { pub url: String, pub title: String }
}

impl<'a> From<&'a nodes::NodeList> for NodeList {
    #[inline]
    fn from(list: &'a nodes::NodeList) -> Self {
        NodeList {
            list_type: match list.list_type {
                nodes::ListType::Bullet => "bullet".into(),
                nodes::ListType::Ordered => "ordered".into(),
            },
            start: list.start,
            delimiter: match list.delimiter {
                nodes::ListDelimType::Period => "period".into(),
                nodes::ListDelimType::Paren => "paren".into(),
            },
            bullet_char: list.bullet_char.to_string(),
            tight: list.tight,
        }
    }
}

impl<'a> From<&'a nodes::NodeCodeBlock> for NodeCodeBlock {
    #[inline]
    fn from(list: &'a nodes::NodeCodeBlock) -> Self {
        NodeCodeBlock {
            fenced: list.fenced,
            fence_char: list.fence_char.to_string(),
            fence_length: list.fence_length,
            info: unsafe { String::from_utf8_unchecked(list.info.clone()) },
            literal: unsafe { String::from_utf8_unchecked(list.literal.clone()) },
        }
    }
}

impl<'a> From<&'a nodes::NodeHtmlBlock> for NodeHtmlBlock {
    #[inline]
    fn from(list: &'a nodes::NodeHtmlBlock) -> Self {
        NodeHtmlBlock {
            literal: unsafe { String::from_utf8_unchecked(list.literal.clone()) },
        }
    }
}

impl<'a> From<&'a nodes::NodeHeading> for NodeHeading {
    #[inline]
    fn from(list: &'a nodes::NodeHeading) -> Self {
        NodeHeading {
            level: list.level,
            setext: list.setext,
        }
    }
}

impl<'a> From<&'a nodes::NodeLink> for NodeLink {
    #[inline]
    fn from(list: &'a nodes::NodeLink) -> Self {
        NodeLink {
            url: unsafe { String::from_utf8_unchecked(list.url.clone()) },
            title: unsafe { String::from_utf8_unchecked(list.title.clone()) },
        }
    }
}

nifs_structs! {
    "Markdown.Native.Document" pub struct Document;
    "Markdown.Native.BlockQuote" pub struct BlockQuote;
    "Markdown.Native.List" pub struct List { pub list: NodeList }
    "Markdown.Native.Item" pub struct Item { pub list: NodeList }
    "Markdown.Native.CodeBlock" pub struct CodeBlock { pub block: NodeCodeBlock }
    "Markdown.Native.HtmlBlock" pub struct HtmlBlock { pub block: NodeHtmlBlock }
    "Markdown.Native.Paragraph" pub struct Paragraph;
    "Markdown.Native.Heading" pub struct Heading { pub heading: NodeHeading }
    "Markdown.Native.ThematicBreak" pub struct ThematicBreak;
    "Markdown.Native.FootnoteDefinition" pub struct FootnoteDefinition { pub name: String }
    "Markdown.Native.Table" pub struct Table { pub alignments: Vec<String> }
    "Markdown.Native.TableRow" pub struct TableRow { pub header: bool }
    "Markdown.Native.TableCell" pub struct TableCell;
    "Markdown.Native.Text" pub struct Text { pub text: String }
    "Markdown.Native.SoftBreak" pub struct SoftBreak;
    "Markdown.Native.LineBreak" pub struct LineBreak;
    "Markdown.Native.Code" pub struct Code { pub code: String }
    "Markdown.Native.HtmlInline" pub struct HtmlInline { pub html: String }
    "Markdown.Native.Emph" pub struct Emph;
    "Markdown.Native.Strong" pub struct Strong;
    "Markdown.Native.Strikethrough" pub struct Strikethrough;
    "Markdown.Native.Superscript" pub struct Superscript;
    "Markdown.Native.Link" pub struct Link { pub link: NodeLink }
    "Markdown.Native.Image" pub struct Image { pub link: NodeLink }
    "Markdown.Native.FootnoteReference" pub struct FootnoteReference { pub name: String }
}

#[inline]
pub fn encode_ast_node<'a, 'b>(env: NifEnv<'a>, node: &'b AstNode<'b>) -> NifTerm<'a> {
    let ast = node.data.borrow();

    let parent = match &ast.value {
        &NodeValue::Document => Document.encode(env),
        &NodeValue::BlockQuote => BlockQuote.encode(env),
        &NodeValue::List(ref list) => List { list: list.into() }.encode(env),
        &NodeValue::Item(ref list) => Item { list: list.into() }.encode(env),
        &NodeValue::CodeBlock(ref block) => CodeBlock {
            block: block.into(),
        }.encode(env),
        &NodeValue::HtmlBlock(ref block) => HtmlBlock {
            block: block.into(),
        }.encode(env),
        &NodeValue::Paragraph => Paragraph.encode(env),
        &NodeValue::Heading(ref heading) => Heading {
            heading: heading.into(),
        }.encode(env),
        &NodeValue::ThematicBreak => ThematicBreak.encode(env),
        &NodeValue::FootnoteDefinition(ref name) => FootnoteDefinition {
            name: unsafe { String::from_utf8_unchecked(name.clone()) },
        }.encode(env),
        &NodeValue::Table(ref alignments) => Table {
            alignments: alignments
                .iter()
                .map(|a| match a {
                    &nodes::TableAlignment::Left => "left".into(),
                    &nodes::TableAlignment::Right => "right".into(),
                    &nodes::TableAlignment::Center => "center".into(),
                    &nodes::TableAlignment::None => String::new(),
                })
                .collect::<Vec<String>>(),
        }.encode(env),
        &NodeValue::TableRow(ref header) => TableRow { header: *header }.encode(env),
        &NodeValue::TableCell => TableCell.encode(env),
        &NodeValue::Text(ref text) => Text {
            text: unsafe { String::from_utf8_unchecked(text.clone()) },
        }.encode(env),
        &NodeValue::SoftBreak => SoftBreak.encode(env),
        &NodeValue::LineBreak => LineBreak.encode(env),
        &NodeValue::Code(ref code) => Code {
            code: unsafe { String::from_utf8_unchecked(code.clone()) },
        }.encode(env),
        &NodeValue::HtmlInline(ref html) => HtmlInline {
            html: unsafe { String::from_utf8_unchecked(html.clone()) },
        }.encode(env),
        &NodeValue::Emph => Emph.encode(env),
        &NodeValue::Strong => Strong.encode(env),
        &NodeValue::Strikethrough => Strikethrough.encode(env),
        &NodeValue::Superscript => Superscript.encode(env),
        &NodeValue::Link(ref link) => Link { link: link.into() }.encode(env),
        &NodeValue::Image(ref link) => Image { link: link.into() }.encode(env),
        &NodeValue::FootnoteReference(ref name) => FootnoteReference {
            name: unsafe { String::from_utf8_unchecked(name.clone()) },
        }.encode(env),
    };

    let children = node.children()
        .map(|n| encode_ast_node(env, n))
        .collect::<Vec<_>>();

    (parent, children).encode(env)
}

#[inline]
pub fn parse<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let text: &'a str = try!(args[0].decode());

    let arena = Arena::new();
    let options = ComrakOptions {
        hardbreaks: true,
        github_pre_lang: true,
        width: 0,
        default_info_string: None,
        ext_strikethrough: true,
        ext_tagfilter: true,
        ext_table: true,
        ext_autolink: true,
        ext_tasklist: true,
        ext_superscript: true,
        ext_header_ids: None,
        ext_footnotes: true,
    };
    let root = parse_document(&arena, text, &options);

    Ok(encode_ast_node(env, root))
}
