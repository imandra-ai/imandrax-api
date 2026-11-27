// ImandraX header behaviour for the HTML API reference (`customJs`)
// =================================================================
//
// For the header that imandrax-theme.mjs renders:
//
// - ⌘K opens the search, as the search field says (typedoc only takes Ctrl+K and /)
// - the light / dark toggle switches typedoc's own Theme setting (the select
//   in the Settings panel), so the two stay in step and the choice is kept
// - the GitHub link shows the repo's stars and forks, fetched once per session
//   as the Python reference does

(() => {
  const root = document.documentElement;
  const darkOS = matchMedia("(prefers-color-scheme: dark)");
  const isDark = () =>
    root.dataset.theme === "dark" || (root.dataset.theme !== "light" && darkOS.matches);

  // Search shortcut
  // ---------------

  document.addEventListener("keydown", (e) => {
    if (!e.metaKey || e.altKey || e.ctrlKey || e.shiftKey || e.key !== "k") return;
    e.preventDefault();
    document.getElementById("tsd-search-trigger")?.click();
  });

  // Theme toggle
  // ------------

  const toggle = document.getElementById("imandrax-theme-toggle");
  const select = document.getElementById("tsd-theme");
  if (toggle) {
    const label = () => {
      const text = isDark() ? "Switch to light mode" : "Switch to dark mode";
      toggle.title = text;
      toggle.setAttribute("aria-label", text);
    };
    label();
    darkOS.addEventListener("change", label);
    select?.addEventListener("change", label);
    toggle.addEventListener("click", () => {
      const theme = isDark() ? "light" : "dark";
      if (select) {
        select.value = theme;
        select.dispatchEvent(new Event("change"));
      } else {
        localStorage.setItem("tsd-theme", theme);
        root.dataset.theme = theme;
        label();
      }
    });
  }

  // GitHub stars and forks
  // ----------------------

  const facts = document.querySelector(".imandrax-source__facts");
  if (!facts) return;
  const key = `imandrax-source:${facts.dataset.repo}`;

  // 1234 -> 1.2k, as Material for MkDocs
  const round = (n) => (n > 999 ? `${(n / 1000).toFixed(1)}k` : `${n}`);
  const show = (counts) => {
    for (const el of facts.querySelectorAll("[data-fact]")) {
      el.textContent = round(counts[el.dataset.fact]);
    }
    facts.hidden = false;
  };

  const cached = sessionStorage.getItem(key);
  if (cached) return show(JSON.parse(cached));
  fetch(`https://api.github.com/repos/${facts.dataset.repo}`)
    .then((res) => (res.ok ? res.json() : Promise.reject(res.status)))
    .then((repo) => {
      const counts = { stars: repo.stargazers_count, forks: repo.forks_count };
      sessionStorage.setItem(key, JSON.stringify(counts));
      show(counts);
    })
    .catch(() => {}); // offline or rate-limited: just "GitHub", without counts
})();
