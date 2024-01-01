use comrak::nodes::{self, AstNode, NodeValue};
use comrak::{
    parse_document, ComrakOptions, ExtensionOptionsBuilder, ParseOptionsBuilder,
    RenderOptionsBuilder,
};
use rustler::{Encoder, Env, NifResult, NifStruct, Term};
use typed_arena::Arena;

rustler::init!("Elixir.Markdown.Native", [parse]);

#[derive(NifStruct)]
#[module = "Markdown.Native.NodeList"]
pub struct NodeList {
    pub list_type: String,
    pub start: usize,
    pub delimiter: String,
    pub bullet_char: String,
    pub tight: bool,
}
#[derive(NifStruct)]
#[module = "Markdown.Native.NodeCodeBlock"]
pub struct NodeCodeBlock {
    pub fenced: bool,
    pub fence_char: String,
    pub fence_length: usize,
    pub info: String,
    pub literal: String,
}
#[derive(NifStruct)]
#[module = "Markdown.Native.NodeHtmlBlock"]
pub struct NodeHtmlBlock {
    pub literal: String,
}
#[derive(NifStruct)]
#[module = "Markdown.Native.NodeHeading"]
pub struct NodeHeading {
    pub level: u8,
    pub setext: bool,
}
#[derive(NifStruct)]
#[module = "Markdown.Native.NodeLink"]
pub struct NodeLink {
    pub url: String,
    pub title: String,
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
            info: list.info.clone(),
            literal: list.literal.clone(),
        }
    }
}

impl<'a> From<&'a nodes::NodeHtmlBlock> for NodeHtmlBlock {
    #[inline]
    fn from(list: &'a nodes::NodeHtmlBlock) -> Self {
        NodeHtmlBlock {
            literal: list.literal.clone(),
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
            url: list.url.clone(),
            title: list.title.clone(),
        }
    }
}

#[derive(NifStruct)]
#[module = "Markdown.Native.Document"]
pub struct Document;

#[derive(NifStruct)]
#[module = "Markdown.Native.BlockQuote"]
pub struct BlockQuote;

#[derive(NifStruct)]
#[module = "Markdown.Native.List"]
pub struct List {
    pub list: NodeList,
}
#[derive(NifStruct)]
#[module = "Markdown.Native.Item"]
pub struct Item {
    pub list: NodeList,
}
#[derive(NifStruct)]
#[module = "Markdown.Native.CodeBlock"]
pub struct CodeBlock {
    pub block: NodeCodeBlock,
}
#[derive(NifStruct)]
#[module = "Markdown.Native.HtmlBlock"]
pub struct HtmlBlock {
    pub block: NodeHtmlBlock,
}
#[derive(NifStruct)]
#[module = "Markdown.Native.Paragraph"]
pub struct Paragraph;

#[derive(NifStruct)]
#[module = "Markdown.Native.Heading"]
pub struct Heading {
    pub heading: NodeHeading,
}
#[derive(NifStruct)]
#[module = "Markdown.Native.ThematicBreak"]
pub struct ThematicBreak;

#[derive(NifStruct)]
#[module = "Markdown.Native.FootnoteDefinition"]
pub struct FootnoteDefinition {
    pub name: String,
}
#[derive(NifStruct)]
#[module = "Markdown.Native.Table"]
pub struct Table {
    pub alignments: Vec<String>,
}
#[derive(NifStruct)]
#[module = "Markdown.Native.TableRow"]
pub struct TableRow {
    pub header: bool,
}
#[derive(NifStruct)]
#[module = "Markdown.Native.TableCell"]
pub struct TableCell;

#[derive(NifStruct)]
#[module = "Markdown.Native.Text"]
pub struct Text {
    pub text: String,
}
#[derive(NifStruct)]
#[module = "Markdown.Native.SoftBreak"]
pub struct SoftBreak;

#[derive(NifStruct)]
#[module = "Markdown.Native.LineBreak"]
pub struct LineBreak;

#[derive(NifStruct)]
#[module = "Markdown.Native.Code"]
pub struct Code {
    pub code: String,
}
#[derive(NifStruct)]
#[module = "Markdown.Native.HtmlInline"]
pub struct HtmlInline {
    pub html: String,
}
#[derive(NifStruct)]
#[module = "Markdown.Native.Emph"]
pub struct Emph;

#[derive(NifStruct)]
#[module = "Markdown.Native.Strong"]
pub struct Strong;

#[derive(NifStruct)]
#[module = "Markdown.Native.Strikethrough"]
pub struct Strikethrough;

#[derive(NifStruct)]
#[module = "Markdown.Native.Superscript"]
pub struct Superscript;

#[derive(NifStruct)]
#[module = "Markdown.Native.Link"]
pub struct Link {
    pub link: NodeLink,
}
#[derive(NifStruct)]
#[module = "Markdown.Native.Image"]
pub struct Image {
    pub link: NodeLink,
}
#[derive(NifStruct)]
#[module = "Markdown.Native.FootnoteReference"]
pub struct FootnoteReference {
    pub name: String,
}

#[inline]
pub fn encode_ast_node<'a, 'b>(env: Env<'a>, node: &'b AstNode<'b>) -> Term<'a> {
    let ast = node.data.borrow();

    let parent = match &ast.value {
        &NodeValue::Document => Document.encode(env),
        &NodeValue::BlockQuote => BlockQuote.encode(env),
        &NodeValue::List(ref list) => List { list: list.into() }.encode(env),
        &NodeValue::Item(ref list) => Item { list: list.into() }.encode(env),
        &NodeValue::CodeBlock(ref block) => CodeBlock {
            block: block.into(),
        }
        .encode(env),
        &NodeValue::HtmlBlock(ref block) => HtmlBlock {
            block: block.into(),
        }
        .encode(env),
        &NodeValue::Paragraph => Paragraph.encode(env),
        &NodeValue::Heading(ref heading) => Heading {
            heading: heading.into(),
        }
        .encode(env),
        &NodeValue::ThematicBreak => ThematicBreak.encode(env),
        &NodeValue::FootnoteDefinition(ref nfd) => FootnoteDefinition {
            name: nfd.name.clone(),
        }
        .encode(env),
        &NodeValue::Table(ref nt) => Table {
            alignments: nt
                .alignments
                .iter()
                .map(|a| match a {
                    &nodes::TableAlignment::Left => "left".into(),
                    &nodes::TableAlignment::Right => "right".into(),
                    &nodes::TableAlignment::Center => "center".into(),
                    &nodes::TableAlignment::None => String::new(),
                })
                .collect::<Vec<String>>(),
        }
        .encode(env),
        &NodeValue::TableRow(ref header) => TableRow { header: *header }.encode(env),
        &NodeValue::TableCell => TableCell.encode(env),
        &NodeValue::Text(ref text) => Text { text: text.clone() }.encode(env),
        &NodeValue::SoftBreak => SoftBreak.encode(env),
        &NodeValue::LineBreak => LineBreak.encode(env),
        &NodeValue::Code(ref nc) => Code {
            code: nc.literal.clone(),
        }
        .encode(env),
        &NodeValue::HtmlInline(ref html) => HtmlInline { html: html.clone() }.encode(env),
        &NodeValue::Emph => Emph.encode(env),
        &NodeValue::Strong => Strong.encode(env),
        &NodeValue::Strikethrough => Strikethrough.encode(env),
        &NodeValue::Superscript => Superscript.encode(env),
        &NodeValue::Link(ref link) => Link { link: link.into() }.encode(env),
        &NodeValue::Image(ref link) => Image { link: link.into() }.encode(env),
        &NodeValue::FootnoteReference(ref nfr) => FootnoteReference {
            name: nfr.name.clone(),
        }
        .encode(env),
        &NodeValue::FrontMatter(_) => unimplemented!(),
        &NodeValue::DescriptionList => unimplemented!(),
        &NodeValue::DescriptionItem(_) => unimplemented!(),
        &NodeValue::DescriptionTerm => unimplemented!(),
        &NodeValue::DescriptionDetails => unimplemented!(),
        &NodeValue::TaskItem(_) => unimplemented!(),
    };

    let children = node
        .children()
        .map(|n| encode_ast_node(env, n))
        .collect::<Vec<_>>();

    (parent, children).encode(env)
}

#[rustler::nif]
pub fn parse<'a>(env: Env<'a>, text: &'a str) -> NifResult<Term<'a>> {
    let arena = Arena::new();

    let extension = ExtensionOptionsBuilder::default()
        .strikethrough(true)
        .tagfilter(true)
        .table(true)
        .autolink(true)
        .tasklist(true)
        .superscript(true)
        .footnotes(true)
        .build()
        .unwrap();

    let parse = ParseOptionsBuilder::default().build().unwrap();

    let render = RenderOptionsBuilder::default()
        .hardbreaks(true)
        .github_pre_lang(true)
        .build()
        .unwrap();

    let options = ComrakOptions {
        extension,
        parse,
        render,
    };
    let root = parse_document(&arena, text, &options);

    Ok(encode_ast_node(env, root))
}
