import { widget, style } from "./lib/repo-status.jsx";

export const { command, refreshFrequency, render } = widget("$HOME/src/JuliaSpacePhysics", "jsp-status-jsx");
export const className = `top: 40px; right: 24px; ${style}`;
