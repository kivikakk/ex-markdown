use rustler::{Env, Term};
use typed_arena::Arena;

mod ast;
mod opts;

rustler::init!(
    "Elixir.Markdown.Native",
    [markdown_to_ast, markdown_to_html]
);

#[rustler::nif]
pub fn markdown_to_ast<'a>(env: Env<'a>, md: &'a str, opts: opts::Options) -> Term<'a> {
    let arena = Arena::new();
    let root = comrak::parse_document(&arena, md, &opts::encode(opts));
    ast::encode_ast_node(env, root)
}

#[rustler::nif]
pub fn markdown_to_html(md: &str, opts: opts::Options) -> String {
    comrak::markdown_to_html(md, &opts::encode(opts))
}
