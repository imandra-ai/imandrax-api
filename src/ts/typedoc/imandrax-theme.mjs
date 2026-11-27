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
// - the footer says which version and commit the reference was built from,
//   unless `customFooterHtml` is set
// - `sidebarLinks` into the repo (`/tree/main/`) point at that commit too
//
// Colours, fonts and sizes are in imandrax.css (`customCss`).

import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { Application, DefaultTheme, DefaultThemeRenderContext, JSX } from "typedoc";

const WORDMARK = readFileSync(new URL("./imandrax-wordmark.svg", import.meta.url), "utf8");
const SITE = "https://imandrax.dev/";
const DOCS = "https://imandrax.dev/docs/";
const REPO = "https://github.com/imandra-ai/imandrax-api";

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

// Top menu link `a`: mark the docs link, open other sites in a new tab
function styleMenuLink(a) {
  const href = a?.props?.href;
  if (typeof href !== "string") return;
  if (href === DOCS) a.props["aria-current"] = "page";
  if (!href.startsWith(SITE)) {
    a.props.target = "_blank";
    a.props.rel = "noopener";
  }
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
      return el;
    };

    // The sidebar repeats the top menu (shown on small screens only) after `sidebarLinks`
    const sidebarLinks = this.sidebarLinks;
    this.sidebarLinks = () => {
      const el = sidebarLinks();
      if (!el) return el;
      mustFind(el, "sidebar links", (e) => e.props?.id === "tsd-sidebar-links")
        .children.flat()
        .filter((a) => a?.props?.class === "tsd-nav-link")
        .forEach(styleMenuLink);
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

function git(...args) {
  return execFileSync("git", args, {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "ignore"],
  }).trim();
}

// The commit being built, or undefined outside a git checkout
function head() {
  try {
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
    const commit = head();
    if (!app.options.isSet("customFooterHtml")) {
      app.options.setValue("customFooterHtml", buildInfo(commit));
    }
    if (commit) {
      const links = app.options.getValue("sidebarLinks");
      const pinned = Object.entries(links).map(([label, href]) => [
        label,
        href.startsWith(`${REPO}/tree/main/`)
          ? href.replace("/tree/main/", `/tree/${commit.commit}/`)
          : href,
      ]);
      app.options.setValue("sidebarLinks", Object.fromEntries(pinned));
    }
  });
}
