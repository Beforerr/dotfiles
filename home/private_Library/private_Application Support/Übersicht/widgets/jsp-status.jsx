import { run } from "uebersicht";

export const command = "$HOME/.local/bin/jsp-status --json";
export const refreshFrequency = 15000;
const LIVE_SECS = 300;

export const className = `
  top: 40px; right: 24px; width: 460px;
  font: 12px Menlo, monospace; color: #eee;
  background: rgba(20,20,24,.72); border-radius: 10px; padding: 10px 12px;
  -webkit-backdrop-filter: blur(12px);
  .repo { margin: 6px 0 2px; }
  .btn { color: #74c0fc; cursor: pointer; margin-left: 10px; }
  .live .name { color: #ffa94d; }
  .name { font-weight: bold; }
  .meta, .files { color: #999; font-size: 11px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .files { color: #bbb; padding-left: 10px; }
`;

const openCode = (p) => `open -a "Visual Studio Code" "${p}"`;
// Orca only opens registered repos, so register on first use.
const ORCA = "/opt/homebrew/bin/orca";
const openOrca = (p) =>
  `${ORCA} open >/dev/null && ` +
  `{ ${ORCA} worktree show --worktree "path:${p}" >/dev/null 2>&1 || ${ORCA} repo add --path "${p}"; } && ` +
  `${ORCA} file open-changed --mode diff --worktree "path:${p}" && open -a Orca`;

const ago = (s) =>
  s < 60 ? `${Math.round(s)}s ago` : s < 3600 ? `${Math.floor(s / 60)}m ago`
  : s < 86400 ? `${Math.floor(s / 3600)}h ago` : `${Math.floor(s / 86400)}d ago`;

export const render = ({ output, error }) => {
  if (error) return <div>jsp-status: {String(error)}</div>;
  let repos;
  try { repos = JSON.parse(output); } catch { return <div>{output}</div>; }
  const now = Date.now() / 1000;
  return (
    <div>
      <div className="meta">{repos.length} dirty · {new Date().toLocaleTimeString()}</div>
      {repos.map((r) => (
        <div key={r.repo} className={now - r.t < LIVE_SECS ? "live" : ""}>
          <div className="repo"><span className="name">{r.repo}</span> ({r.files.length}) {r.desc}</div>
          <div className="meta">
            {ago(now - r.t)}
            <span className="btn" onClick={() => run(openCode(r.path))}>VS Code</span>
            <span className="btn" onClick={() => run(openOrca(r.path))}>Orca</span>
          </div>
          {r.files.slice(0, 5).map((f) => <div className="files" key={f}>{f}</div>)}
          {r.files.length > 5 && <div className="files">… +{r.files.length - 5}</div>}
        </div>
      ))}
    </div>
  );
};
