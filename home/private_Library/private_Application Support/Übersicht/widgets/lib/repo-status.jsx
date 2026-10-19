import { run } from "uebersicht";

const LIVE_SECS = 300;

// Widgets set position: className = `top: ..; right: ..; ${style}`.
export const style = `
  width: 460px;
  font: 12px Menlo, monospace; color: #eee;
  background: rgba(20,20,24,.72); border-radius: 10px; padding: 10px 12px;
  -webkit-backdrop-filter: blur(12px);
  .repo { margin: 6px 0 2px; cursor: pointer; }
  .live .name { color: #ffa94d; }
  .name { font-weight: bold; }
  .meta, .files { color: #999; font-size: 11px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .files { color: #bbb; padding-left: 10px; }
  .meta span { margin-left: 8px; }
  .warn { color: #ffd43b; } .bad { color: #ff6b6b; } .good { color: #69db7c; }
`;

const openCode = (p) => `open -a "Visual Studio Code" "${p}"`;
const openOrca = (p) => `$HOME/.local/bin/orca-focus "${p}"`;

const CI = { success: ["✓", "good"], failure: ["✗", "bad"], pending: ["…", "warn"] };
const link = (url) => (e) => { e.stopPropagation(); url && run(`open "${url}"`); };
const [ciMark, ciClass] = [(r) => (CI[r.ci] || [""])[0], (r) => (CI[r.ci] || [])[1]];
// Übersicht's shell lacks the brew/cargo PATH; failures open the log.
const merge = (r, id) => (e) => {
  e.stopPropagation();
  run(`osascript -e 'display dialog "Merge ${r.repo} #${r.pr}?"' >/dev/null || exit 0
    export PATH=$HOME/.cargo/bin:/opt/homebrew/bin:$PATH
    cd "${r.path}" && $HOME/.local/bin/pr-merge ${r.pr} > "${r.log}" 2>&1 \
      && osascript -e 'display notification "${r.repo} #${r.pr} merged"' || open -t "${r.log}"
    osascript -e 'tell application id "tracesOf.Uebersicht" to refresh widget id "${id}"'`);
};

const badges = (r, id) => [
  r.ahead > 0 && <span key="a" title="commits off main">↑{r.ahead}</span>,
  r.behind > 0 && <span key="b" className="warn" title="main commits not in @">↓{r.behind}</span>,
  r.conflict > 0 && <span key="c" className="bad">conflict</span>,
  r.divergent > 0 && <span key="d" className="bad">divergent</span>,
  r.working > 0 && <span key="w" className="good" title="agents working">⚙{r.working}</span>,
  r.waiting > 0 && <span key="q" className="bad" title="agents waiting on you">✋{r.waiting}</span>,
  r.pr
    ? <span key="pr" className={ciClass(r)} onClick={link(r.ci && r.ci !== "success" ? r.ciurl : r.prurl)}>
        #{r.pr}{r.prstate !== "open" && ` ${r.prstate}`} {ciMark(r)}</span>
    : r.ci && <span key="ci" className={ciClass(r)} onClick={link(r.ciurl)}>CI {ciMark(r)}</span>,
  r.pr && r.prstate === "open" && r.ci === "success" &&
    <span key="m" className="good" title="merge PR (pr-merge)" onClick={merge(r, id)}>⇲ merge</span>,
];

const ago = (s) =>
  s < 60 ? `${Math.round(s)}s ago` : s < 3600 ? `${Math.floor(s / 60)}m ago`
  : s < 86400 ? `${Math.floor(s / 3600)}h ago` : `${Math.floor(s / 86400)}d ago`;

// id: Übersicht widget id (file path with "/" and "." as "-"), for refresh after merge.
export const widget = (root, id) => ({
  command: `$HOME/.local/bin/repo-status --json "${root}"`,
  refreshFrequency: 30000,
  render: ({ output, error }) => render(output, error, root.split("/").pop(), id),
});

const render = (output, error, name, id) => {
  if (error) return <div>repo-status: {String(error)}</div>;
  let repos;
  try { repos = JSON.parse(output); } catch { return <div>{output}</div>; }
  const now = Date.now() / 1000;
  return (
    <div>
      <div className="meta">{name}: {repos.length} with work · {new Date().toLocaleTimeString()} · click VS Code, ⌥-click Orca</div>
      {repos.map((r) => (
        <div key={r.repo} className={now - r.t < LIVE_SECS ? "live" : ""}
             onClick={(e) => run((e.altKey ? openOrca : openCode)(r.path))}>
          <div className="repo"><span className="name">{r.repo}</span> ({r.files.length}) {r.desc}</div>
          <div className="meta">{ago(now - r.t)}{badges(r, id)}</div>
          {r.files.slice(0, 5).map((f) => <div className="files" key={f}>{f}</div>)}
          {r.files.length > 5 && <div className="files">… +{r.files.length - 5}</div>}
        </div>
      ))}
    </div>
  );
};
