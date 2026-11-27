// ImandraX theme for the HTML API reference (`npm run docs:html`)
// ===============================================================
//
// The default typedoc theme with imandrax.dev's header, since this reference is
// published there (imandrax.dev/docs/api/typescript-client/), next to the Python
// reference (whose header is src/py/overrides/partials/header.html).
//
// - the title is the ImandraX wordmark, linking to `titleLink`
// - the `navigationLinks` are imandrax.dev's top menu; the docs link is marked
//   current and links off imandrax.dev open in a new tab, in the header and
//   in the sidebar (where typedoc repeats them on small screens)
// - laid out as the Python reference's header: the search button becomes a
//   search field next to the wordmark; after the top menu come the GitHub repo
//   with its stars and forks, and a light / dark toggle (imandrax.js fills in
//   the counts and runs the toggle); the GitHub `sidebarLinks` entry then only
//   shows on small screens, where the header has no room for it
// - the footer says which version and commit the reference was built from,
//   unless `customFooterHtml` is set
//
// Colours, fonts and sizes are in imandrax.css (`customCss`).

import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { Application, DefaultTheme, DefaultThemeRenderContext, JSX } from "typedoc";

const WORDMARK = readFileSync(new URL("./imandrax-wordmark.svg", import.meta.url), "utf8");
// imandrax.dev links are root-relative: the reference is only served there
const SITE = "/";
const DOCS = "/docs/";
const REPO = "https://github.com/imandra-ai/imandrax-api";

// The Python reference's icons (Material for MkDocs): Font Awesome git-alt,
// Lucide search / star / git-fork, Material Design brightness-7 / brightness-4
const svg = (viewBox, body, attrs = 'fill="currentColor"') =>
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${viewBox}" ${attrs} aria-hidden="true">${body}</svg>`;
const LUCIDE =
  'fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"';
const ICONS = {
  git: svg(
    "0 0 448 512",
    '<path d="M439.6 236.1 244 40.5c-5.4-5.5-12.8-8.5-20.4-8.5s-15 3-20.4 8.4L162.5 81l51.5 51.5c27.1-9.1 52.7 16.8 43.4 43.7l49.7 49.7c34.2-11.8 61.2 31 35.5 56.7-26.5 26.5-70.2-2.9-56-37.3L240.3 199v121.9c25.3 12.5 22.3 41.8 9.1 55-6.4 6.4-15.2 10.1-24.3 10.1s-17.8-3.6-24.3-10.1c-17.6-17.6-11.1-46.9 11.2-56v-123c-20.8-8.5-24.6-30.7-18.6-45L142.6 101 8.5 235.1C3 240.6 0 247.9 0 255.5s3 15 8.5 20.4l195.6 195.7c5.4 5.4 12.7 8.4 20.4 8.4s15-3 20.4-8.4l194.7-194.7c5.4-5.4 8.4-12.8 8.4-20.4s-3-15-8.4-20.4"/>',
  ),
  star: svg(
    "0 0 24 24",
    '<path d="M11.525 2.295a.53.53 0 0 1 .95 0l2.31 4.679a2.12 2.12 0 0 0 1.595 1.16l5.166.756a.53.53 0 0 1 .294.904l-3.736 3.638a2.12 2.12 0 0 0-.611 1.878l.882 5.14a.53.53 0 0 1-.771.56l-4.618-2.428a2.12 2.12 0 0 0-1.973 0L6.396 21.01a.53.53 0 0 1-.77-.56l.881-5.139a2.12 2.12 0 0 0-.611-1.879L2.16 9.795a.53.53 0 0 1 .294-.906l5.165-.755a2.12 2.12 0 0 0 1.597-1.16z"/>',
    LUCIDE,
  ),
  search: svg("0 0 24 24", '<path d="m21 21-4.34-4.34"/><circle cx="11" cy="11" r="8"/>', LUCIDE),
  fork: svg(
    "0 0 24 24",
    '<circle cx="12" cy="18" r="3"/><circle cx="6" cy="6" r="3"/><circle cx="18" cy="6" r="3"/><path d="M18 9v2c0 .6-.4 1-1 1H7c-.6 0-1-.4-1-1V9M12 12v3"/>',
    LUCIDE,
  ),
  light: svg(
    "0 0 24 24",
    '<path d="M12 8a4 4 0 0 0-4 4 4 4 0 0 0 4 4 4 4 0 0 0 4-4 4 4 0 0 0-4-4m0 10a6 6 0 0 1-6-6 6 6 0 0 1 6-6 6 6 0 0 1 6 6 6 6 0 0 1-6 6m8-9.31V4h-4.69L12 .69 8.69 4H4v4.69L.69 12 4 15.31V20h4.69L12 23.31 15.31 20H20v-4.69L23.31 12z"/>',
  ),
  dark: svg(
    "0 0 24 24",
    '<path d="M12 18c-.89 0-1.74-.2-2.5-.55C11.56 16.5 13 14.42 13 12s-1.44-4.5-3.5-5.45C10.26 6.2 11.11 6 12 6a6 6 0 0 1 6 6 6 6 0 0 1-6 6m8-9.31V4h-4.69L12 .69 8.69 4H4v4.69L.69 12 4 15.31V20h4.69L12 23.31 15.31 20H20v-4.69L23.31 12z"/>',
  ),
};

// Header
// ------

// Find the first element below `el` (depth first) that `pred` accepts
function find(el, pred) {
  if (Array.isArray(el)) {
    for (const child of el) {
      const found = find(child, pred);
      if (found) return found;
    }
    return undefined;
  }
  if (!el || typeof el !== "object" || !("tag" in el)) return undefined;
  if (pred(el)) return el;
  return find(el.children, pred);
}

function mustFind(el, what, pred) {
  const found = find(el, pred);
  // The default theme's markup changed: update this theme to match
  if (!found) throw new Error(`imandrax-theme: no ${what} in typedoc's output`);
  return found;
}

// Top menu link `a`: mark the docs link as the current section (`true`, not
// `page`: it links to the docs home), open other sites in a new tab
function styleMenuLink(a) {
  const href = a?.props?.href;
  if (typeof href !== "string") return;
  if (href === DOCS) a.props["aria-current"] = "true";
  if (!href.startsWith(SITE)) {
    a.props.target = "_blank";
    a.props.rel = "noopener";
  }
}

const raw = (html) => JSX.createElement(JSX.Raw, { html });

// GitHub repo; imandrax.js fills in the counts and unhides them
function repoLink() {
  const fact = (name) =>
    JSX.createElement(
      "span",
      { class: `imandrax-source__fact imandrax-source__fact--${name}` },
      raw(ICONS[name === "stars" ? "star" : "fork"]),
      JSX.createElement("span", { "data-fact": name }),
    );
  return JSX.createElement(
    "a",
    {
      href: REPO,
      class: "imandrax-source",
      title: "Go to repository",
      target: "_blank",
      rel: "noopener",
    },
    JSX.createElement("span", { class: "imandrax-source__icon" }, raw(ICONS.git)),
    JSX.createElement(
      "span",
      { class: "imandrax-source__repository" },
      "GitHub",
      JSX.createElement(
        "span",
        {
          class: "imandrax-source__facts",
          "data-repo": new URL(REPO).pathname.slice(1),
          hidden: true,
        },
        fact("stars"),
        fact("forks"),
      ),
    ),
  );
}

// Light / dark toggle; imandrax.css shows the icon of the current scheme,
// imandrax.js sets the label and switches typedoc's Theme setting
function themeToggle() {
  return JSX.createElement(
    "button",
    {
      type: "button",
      id: "imandrax-theme-toggle",
      class: "tsd-widget",
      "aria-label": "Switch light / dark mode",
    },
    JSX.createElement("span", { class: "imandrax-theme-toggle__light" }, raw(ICONS.light)),
    JSX.createElement("span", { class: "imandrax-theme-toggle__dark" }, raw(ICONS.dark)),
  );
}

class ImandraXContext extends DefaultThemeRenderContext {
  constructor(router, theme, page, options) {
    super(router, theme, page, options);
    const toolbar = this.toolbar;
    this.toolbar = (props) => {
      const el = toolbar(props);

      const title = mustFind(el, "title link", (e) => e.props?.class === "title");
      title.props["aria-label"] = "ImandraX Home";
      title.props.title = "ImandraX";
      title.children = [JSX.createElement(JSX.Raw, { html: WORDMARK })];

      const links = mustFind(el, "toolbar links", (e) => e.props?.id === "tsd-toolbar-links");
      links.children.flat().forEach(styleMenuLink);

      const contents = mustFind(el, "toolbar contents", (e) =>
        e.props?.class?.startsWith("tsd-toolbar-contents"),
      );
      const children = contents.children.flat(Infinity);
      const take = (id) => {
        const i = children.findIndex((e) => e?.props?.id === id);
        if (i < 0) throw new Error(`imandrax-theme: no #${id} in typedoc's output`);
        return children.splice(i, 1)[0];
      };
      const search = take("tsd-search-trigger");
      const dialog = take("tsd-search");
      search.props.class = "tsd-widget imandrax-search";
      search.children = [
        raw(ICONS.search),
        JSX.createElement("span", { class: "imandrax-search__label" }, "Search"),
        JSX.createElement("kbd", { class: "imandrax-search__key" }, "⌘K"),
      ];
      children.splice(children.indexOf(title) + 1, 0, search, dialog);
      children.splice(children.indexOf(links) + 1, 0, repoLink(), themeToggle());
      contents.children = children;
      return el;
    };

    // The sidebar repeats the top menu (shown on small screens only) after
    // `sidebarLinks`; the GitHub link joins it, as the header has it otherwise
    const sidebarLinks = this.sidebarLinks;
    this.sidebarLinks = () => {
      const el = sidebarLinks();
      if (!el) return el;
      const navLinks = mustFind(
        el,
        "sidebar links",
        (e) => e.props?.id === "tsd-sidebar-links",
      ).children.flat();
      for (const a of navLinks) {
        if (a?.props?.href?.startsWith(REPO)) a.props.class = "tsd-nav-link";
      }
      navLinks.filter((a) => a?.props?.class === "tsd-nav-link").forEach(styleMenuLink);
      return el;
    };
  }
}

class ImandraXTheme extends DefaultTheme {
  getRenderContext(page) {
    return new ImandraXContext(this.router, this, page, this.application.options);
  }
}

// Build info
// ----------

// Run git in this file's directory, whatever directory typedoc runs in
function git(...args) {
  return execFileSync("git", args, {
    cwd: new URL(".", import.meta.url),
    encoding: "utf8",
    stdio: ["ignore", "pipe", "ignore"],
  }).trim();
}

// The commit being built, or undefined unless this file is in an imandrax-api
// checkout (a copy without .git inside another repo would find that repo)
function head() {
  try {
    if (git("rev-parse", "--show-prefix") !== "src/ts/typedoc/") return undefined;
    const [commit, short, date] = git("log", "-1", "--format=%H %h %cs").split(" ");
    return { commit, short, date };
  } catch {
    return undefined;
  }
}

// "@imandra/imandrax-api 0.21.0, commit <a>d00bf1e</a> (2026-11-26)"; without git, only the version
function buildInfo(commit) {
  const pkg = JSON.parse(readFileSync(new URL("../package.json", import.meta.url), "utf8"));
  const info = `${pkg.name} ${pkg.version}`;
  if (!commit) return info;
  return `${info}, commit <a href="${REPO}/commit/${commit.commit}">${commit.short}</a> (${commit.date})`;
}

/** @param {import("typedoc").Application} app */
export function load(app) {
  app.renderer.defineTheme("imandrax", ImandraXTheme);
  app.on(Application.EVENT_BOOTSTRAP_END, () => {
    if (!app.options.isSet("customFooterHtml")) {
      app.options.setValue("customFooterHtml", buildInfo(head()));
    }
  });
}
