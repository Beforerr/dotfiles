import { widget, style } from "./lib/repo-status.jsx";

export const { command, refreshFrequency, render } = widget("$HOME/projects", "projects-status-jsx");
export const className = `top: 40px; right: 508px; ${style}`;
