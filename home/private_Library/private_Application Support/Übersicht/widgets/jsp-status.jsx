import { run } from "uebersicht";

export const command = "$HOME/.local/bin/jsp-status --json";
export const refreshFrequency = 15000;
const LIVE_SECS = 300;

export const className = `
  top: 40px; right: 24px; width: 460px;
  font: 12px Menlo, monospace; color: #eee;
  background: rgba(20,20,24,.72); border-radius: 10px; padding: 10px 12px;
  -webkit-backdrop-filter: blur(12px);
  .repo { margin: 6px 0 2px; cursor: pointer; }
  .live .name { color: #ffa94d; }
  .name { font-weight: bold; }
  .meta, .files { color: #999; font-size: 11px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .files { color: #bbb; padding-left: 10px; }
`;

const openCode = (p) => `open -a "Visual Studio Code" "${p}"`;
const openOrca = (p) => `$HOME/.local/bin/orca-focus "${p}"`;

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
      <div className="meta">{repos.length} dirty · {new Date().toLocaleTimeString()} · click VS Code, ⌥-click Orca</div>
      {repos.map((r) => (
        <div key={r.repo} className={now - r.t < LIVE_SECS ? "live" : ""}
             onClick={(e) => run((e.altKey ? openOrca : openCode)(r.path))}>
          <div className="repo"><span className="name">{r.repo}</span> ({r.files.length}) {r.desc}</div>
          <div className="meta">{ago(now - r.t)}</div>
          {r.files.slice(0, 5).map((f) => <div className="files" key={f}>{f}</div>)}
          {r.files.length > 5 && <div className="files">… +{r.files.length - 5}</div>}
        </div>
      ))}
    </div>
  );
};
