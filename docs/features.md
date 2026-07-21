# Knopo user guide

Knopo is a local-first macOS outliner. Notes live in a **graph**: a folder of
plain Markdown files that remains readable and editable without Knopo. The app
adds block editing, links, backlinks, search, tags, embeds, and live queries on
top of those files.

This page introduces Knopo's concepts and everyday features. See also the
[command reference](commands.md) and [query syntax](query-syntax.md).

## Start with a graph

Choose **File > Open Graph…** (`⌘O`) to open an existing folder or create a new
one. A graph contains one knowledge base:

```text
graph/
  pages/       ordinary pages
  journals/    daily journal pages
  assets/      imported images
  .knopo/      settings and a rebuildable search index
```

Knopo opens the last-used graph on the next launch. The journal is the home
view, so a new graph opens on today's notes.

## Blocks and outlines

A **block** is one item in an outline. It may contain text, Markdown, properties,
or multiple lines, and it may have child blocks. The block and all of its
descendants form a subtree.

- Press `Enter` to split a block and create a sibling.
- Press `Tab` and `⇧Tab` to indent and outdent.
- Press `⌥↑` and `⌥↓` to move a block and its subtree.
- Click the disclosure triangle to collapse or expand children.
- Click a bullet to **zoom in**, making that block the temporary root. Use the
  breadcrumb above the outline to move back up.
- Drag a bullet to move a block. Drop between rows to make it a sibling, or onto
  a row to make it that block's first child.

Press `Esc` while editing to select the whole block. From block selection you
can extend the selection with `⇧↑` and `⇧↓`, then indent, move, copy, paste, or
delete all selected blocks together. A selected parent carries its subtree with
it.

Blocks can be empty. An empty leaf hides its bullet when it is not focused, but
remains available for editing.

### Editing and Markdown

The focused block shows its raw Markdown source. Unfocused blocks show rendered
content. Knopo supports:

- `**bold**`, `*italic*`, `~~strikethrough~~`, and `==highlight==`
- inline code with backticks and fenced code blocks
- headings (`#` through `######`), quotes (`> `), and horizontal rules (`---`)
- `[label](https://example.com)` links and bare `http://` or `https://` URLs
- images, including optional display sizes
- `TODO` and `DONE` task markers at the start of a block
- inline `$math$`, currently displayed as styled source rather than typeset math

Underscores do not create emphasis, so names such as `file_name.md` remain
literal. Put a backslash before a Markdown trigger to escape it; for example,
`\#not-a-tag` displays as `#not-a-tag` without creating a tag.

Setext headings, footnotes, HTML rendering, and GitHub-style table rendering are
not supported. Their source is preserved, but unsupported syntax is displayed
as plain text. A prefix such as `1.` is ordinary block text rather than an
ordered-list marker. The outline's bullets and indentation define structure.

Use `⇧Enter` for a newline inside one block. In a fenced code block, plain
`Enter` also inserts a newline while the caret is inside the fence, and `Tab`
indents code instead of the outline.

Right-click a bullet and choose **Background Color** to tint that block. The
color applies to the block itself, not its children.

## Pages

A **page** is a named tree of blocks backed by one Markdown file. Page names are
case-insensitively unique, while the spelling used when the page was created is
kept for display.

Open **All Pages** in the left sidebar to browse, filter, create, favourite, or
delete pages. A name such as `Projects/Knopo` is shown in a namespace group in
All Pages, but it is still one flat page; namespaces do not inherit content or
settings.

A page may exist as a **stub**: a page reference has named it, but no file exists
yet. A stub is navigable and has backlinks. Knopo creates its file when content
is first added.

The page menu (`…`) provides page actions such as favourite, rename, open in the
right sidebar, and delete. Renaming updates page references throughout the
graph. Deleting sends the file to the macOS Trash; incoming page links then lead
to a stub.

## Page references

A **page reference** links a block to a page:

```markdown
Discuss this in [[Project Knopo]].
```

Type `[[` to search for a page or create a reference to a new stub, then press
`Enter` or `Tab` to complete it. A normal click opens the page. `⌘`-click or
`⇧`-click opens it in the right sidebar. Hover over a page reference to preview
the beginning of the page.

Date references use a stable ISO name such as `[[2026-07-21]]`, but render using
the configured friendly date format.

## Block references

A **block reference** points to one specific block by its durable ID:

```markdown
((6f1c9e2a-3b4d-4c5e-8f90-1a2b3c4d5e6f))
```

Type `((` and search block content to insert one, or right-click a bullet and
choose **Copy Block Reference**. Knopo stores an `id::` property on the source
block when it first becomes a reference target.

An unfocused reference displays the source block's current content. It does not
include the source block's children. Click it to navigate to the source. Edit the
source rather than the displayed reference.

If the source block is deleted, the reference remains visible as a broken
reference. Knopo asks for confirmation before deleting blocks with incoming
references.

## Embeds

An **embed** displays source content as a read-only outline inside another
block:

```markdown
{{embed [[Project Knopo]]}}
{{embed ((6f1c9e2a-3b4d-4c5e-8f90-1a2b3c4d5e6f))}}
```

| Form | What it displays |
|---|---|
| Page embed | All blocks on the referenced page |
| Block embed | The referenced block and its full subtree |
| Plain block reference | Only the referenced block's own content |

Use `/page-embed` or `/block-embed` to insert an embed and choose its target.
Click embedded content to navigate to the source. Embedded content cannot be
edited in place, although a `TODO`/`DONE` checkbox inside it can update its
source block. Nested embeds are shown literally to prevent cycles.

Both references and embeds count as links to their source and therefore appear
in backlinks.

## Linked and unlinked references

Every page has a references area below its outline.

**Linked References** lists blocks elsewhere in the graph that contain a page
reference to this page or a block reference to one of this page's blocks. Results
are grouped by source page and include breadcrumbs for context. Self-references
are omitted. Linked-reference blocks can be edited in place; the change is
written to their source page.

**Unlinked References** finds plain-text mentions of the page name that are not
yet links. Choose **Link** beside a result to wrap that mention in `[[...]]` in
the source block.

## Tags

A **tag** is a case-insensitive label, not a page:

```markdown
#urgent
#[[in progress]]
```

Type `#` to autocomplete existing tags. Click a rendered tag to open its
generated tag view: a read-only list of matching blocks grouped by page. Tags
have no page content, do not appear in page autocomplete, and do not create page
backlinks.

The left sidebar shows frequently used tags with occurrence counts. Tags can be
favourited and renamed; renaming updates their occurrences across the graph.
Use a [query](query-syntax.md) when you need tag intersections or want to combine
a tag with a task, page reference, or property.

## Queries

A **query** is a live filter whose results appear inside its host block:

```markdown
{{query #work TODO}}
{{query (and #urgent (not DONE))}}
```

Queries can filter by tags, page references, `TODO`/`DONE` state, and block or
page properties. Filters can be combined with `and`, `or`, and `not`. Type
`/query` to insert a query skeleton.

Results are read-only and grouped by page. Click a result to navigate to its
source; task checkboxes update the source block. See [Query syntax](query-syntax.md)
for the complete language and current limitations.

## Tasks and properties

Start a block with `TODO ` or `DONE ` to give it a task state. Click its checkbox
or press `⌘Enter` to toggle `TODO` and `DONE`; on a plain block, `⌘Enter` first
adds `TODO`. Tasks are lightweight markers; Knopo does not add scheduling or a
separate task manager.

A property is a `key:: value` line. In a block, put property lines after the
block's content:

```markdown
- Prepare the release
  status:: active
  owner:: Alex
```

Properties are displayed below rendered block content and can be used in
queries. Unbulleted property lines before the page's first block are page-level
properties:

```markdown
type:: project
status:: active
- First project note
```

Page-level properties can make the page itself appear in a property query. The
special first-block property `title::` overrides the page's displayed title; the
page's link identity and filename remain unchanged.

## Journal

Knopo's home view is a journal with one page per calendar day. Today is always
shown, followed by previous non-empty days in reverse chronological order. A
journal is an ordinary page in every other respect: it can contain blocks, be
referenced, be favourited, and show backlinks.

Use `⌘J` to return to the journal. Right-click **Journal** in the sidebar and
choose **Jump to Day…** to navigate to another date. Slash commands such as
`/today`, `/tomorrow`, `/yesterday`, and `/date` insert date references.

Knopo also recognizes Logseq journal filenames that use underscores, such as
`2026_07_21.md`, as the same calendar identity as `2026-07-21`.

## Search, find, and navigation

- **Search** (`⌘K`) searches page names and all indexed block text. Page matching
  is fuzzy; block full-text search matches token prefixes. For example, `log`
  matches `logging` but not `catalog`.
- **Find in Page** (`⌘F`) finds substrings in the visible outline. On the journal
  home it searches all currently rendered days. Use `⌘G` and `⇧⌘G` to move
  between matches.
- **Back** and **Forward** (`⌘[` and `⌘]`) move through navigation history.
- **Favourites**, **Recents**, **Tags**, and **All Pages** live in the left
  sidebar. Recents can be cleared from the View menu.
- The **right sidebar** holds a stack of page or tag panes for side-by-side
  reference work. Use `⌘`-click or `⇧`-click on internal links and sidebar rows
  to open them there.
- Multiple windows or native tabs can show the same graph or different graphs.
  Views of the same graph share content, index updates, and undo history.

## Images and assets

Drag image files from Finder into an outline, paste copied image files or bitmap
data, or use `/image`. Knopo copies imported files into the graph's `assets/`
folder and inserts portable Markdown.

Hover over a rendered image and drag its right-edge handle to resize it while
preserving its aspect ratio. Resizing changes the Markdown to an Obsidian-style
width form such as:

```markdown
![diagram|640](../assets/diagram.png)
```

Deleting or undoing the block does not delete the imported asset file.

## Your files and external edits

Pages are Markdown bullet lists; two-space indentation stores the outline tree.
Knopo preserves untouched source byte-for-byte, including Markdown it does not
interpret. Content before the first bullet is preserved and displayed read-only
as a page preamble; edit the file directly to change that preamble.

Knopo watches the graph for external file edits and refreshes its index. If an
external edit conflicts with unsaved in-app changes, the last writer wins and
the losing version is saved under `.knopo/conflicts/`.

The SQLite index at `.knopo/cache.db` is rebuildable. Page and journal Markdown
files are the source of note content; `.knopo/config.json` stores favourites and
settings and should be backed up with the graph.
