use comrak::{
    ComrakOptions, ExtensionOptionsBuilder, ListStyleType, ParseOptionsBuilder,
    RenderOptionsBuilder,
};
use rustler::{NifStruct, NifUnitEnum};

#[derive(NifStruct)]
#[module = "Markdown.Renderer.Options"]
pub struct Options {
    // extensions
    pub strikethrough: bool,
    pub tagfilter: bool,
    pub table: bool,
    pub autolink: bool,
    pub tasklist: bool,
    pub superscript: bool,
    pub header_ids: Option<String>,
    pub footnotes: bool,
    pub description_lists: bool,
    pub front_matter_delimiter: Option<String>,
    // parse options
    pub smart: bool,
    pub default_info_string: Option<String>,
    pub relaxed_tasklist_matching: bool,
    pub relaxed_autolinks: bool,
    // render options
    pub hardbreaks: bool,
    pub github_pre_lang: bool,
    pub full_info_string: bool,
    pub width: usize,
    pub unsafe_: bool,
    pub escape: bool,
    pub list_style: ListStyle,
    pub sourcepos: bool,
}

#[derive(NifUnitEnum)]
pub enum ListStyle {
    Dash,
    Plus,
    Star,
}

impl Into<ListStyleType> for ListStyle {
    fn into(self) -> ListStyleType {
        match self {
            Self::Dash => ListStyleType::Dash,
            Self::Plus => ListStyleType::Plus,
            Self::Star => ListStyleType::Star,
        }
    }
}

pub(crate) fn encode(opts: Options) -> ComrakOptions {
    let extension = ExtensionOptionsBuilder::default()
        .strikethrough(opts.strikethrough)
        .tagfilter(opts.tagfilter)
        .table(opts.table)
        .autolink(opts.autolink)
        .tasklist(opts.tasklist)
        .superscript(opts.superscript)
        .header_ids(opts.header_ids)
        .footnotes(opts.footnotes)
        .description_lists(opts.description_lists)
        .front_matter_delimiter(opts.front_matter_delimiter)
        .build()
        .unwrap();

    let parse = ParseOptionsBuilder::default()
        .smart(opts.smart)
        .default_info_string(opts.default_info_string)
        .relaxed_tasklist_matching(opts.relaxed_tasklist_matching)
        .relaxed_autolinks(opts.relaxed_autolinks)
        .build()
        .unwrap();

    let render = RenderOptionsBuilder::default()
        .hardbreaks(opts.hardbreaks)
        .github_pre_lang(opts.github_pre_lang)
        .full_info_string(opts.full_info_string)
        .width(opts.width)
        .unsafe_(opts.unsafe_)
        .escape(opts.escape)
        .list_style(opts.list_style.into())
        .sourcepos(opts.sourcepos)
        .build()
        .unwrap();

    return ComrakOptions {
        extension,
        parse,
        render,
    }
}

