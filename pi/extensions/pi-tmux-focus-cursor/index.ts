import { watch, type FSWatcher } from "node:fs";
import { mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { CustomEditor, type ExtensionAPI, type ExtensionContext } from "@mariozechner/pi-coding-agent";
import { CURSOR_MARKER } from "@mariozechner/pi-tui";

const TMUX_PANE = process.env.TMUX_PANE;
const HOOK_ID = process.pid;
const STATE_DIR = join(tmpdir(), "pi-tmux-pane-cursor");
const STATE_FILE = TMUX_PANE
	? join(STATE_DIR, `pane-${TMUX_PANE.replace(/[^a-zA-Z0-9_.-]/g, "_")}-${HOOK_ID}.state`)
	: undefined;
const TMUX_TIMEOUT_MS = 500;

function shellQuote(value: string): string {
	return `'${value.replace(/'/g, `'\\''`)}'`;
}

function stripFakeCursor(line: string): string {
	const markerIndex = line.indexOf(CURSOR_MARKER);
	if (markerIndex === -1) return line;

	const withoutMarker = line.replace(CURSOR_MARKER, "");
	const afterMarker = withoutMarker.slice(markerIndex);
	const match = afterMarker.match(/^\x1b\[7m([\s\S])\x1b\[0m/);
	if (!match) return withoutMarker;

	const highlightedChar = match[1] ?? "";
	const trailingText = afterMarker.slice(match[0].length);
	const replacement = highlightedChar === " " && /^\s*$/.test(trailingText) ? "" : highlightedChar;

	return withoutMarker.slice(0, markerIndex) + replacement + trailingText;
}

class TmuxPaneAwareEditor extends CustomEditor {
	private tmuxPaneFocused = true;
	private forceCursorHidden = false;

	setTmuxPaneFocused(focused: boolean): void {
		if (this.tmuxPaneFocused === focused) return;
		this.tmuxPaneFocused = focused;
		this.invalidate();
		this.tui.requestRender();
	}

	prepareForExit(): void {
		this.forceCursorHidden = true;
		this.invalidate();
		this.tui.requestRender();
	}

	render(width: number): string[] {
		const lines = super.render(width);
		if (this.tmuxPaneFocused && !this.forceCursorHidden) return lines;
		return lines.map(stripFakeCursor);
	}
}

export default function (pi: ExtensionAPI) {
	let currentEditor: TmuxPaneAwareEditor | null = null;
	let stateWatcher: FSWatcher | undefined;
	let hooksInstalled = false;
	let isTmuxPaneFocused = true;

	async function runTmux(args: string[]): Promise<void> {
		await pi.exec("tmux", args, { timeout: TMUX_TIMEOUT_MS });
	}

	async function applyStateFromFile(): Promise<void> {
		if (!STATE_FILE) return;
		try {
			const nextFocused = (await readFile(STATE_FILE, "utf8")).trim() !== "0";
			if (nextFocused === isTmuxPaneFocused) return;
			isTmuxPaneFocused = nextFocused;
			currentEditor?.setTmuxPaneFocused(nextFocused);
		} catch {
			// Ignore transient read errors while tmux is updating the state file.
		}
	}

	function hookCommand(value: "0" | "1"): string {
		return `run-shell -b \"printf %s ${value} > ${shellQuote(STATE_FILE!)}\"`;
	}

	async function installHooks(): Promise<void> {
		if (!TMUX_PANE || !STATE_FILE || hooksInstalled) return;
		await mkdir(STATE_DIR, { recursive: true });
		await writeFile(STATE_FILE, isTmuxPaneFocused ? "1" : "0");
		await runTmux(["set-hook", "-p", "-t", TMUX_PANE, `pane-focus-in[${HOOK_ID}]`, hookCommand("1")]);
		await runTmux(["set-hook", "-p", "-t", TMUX_PANE, `pane-focus-out[${HOOK_ID}]`, hookCommand("0")]);
		hooksInstalled = true;
	}

	async function uninstallHooks(): Promise<void> {
		if (!TMUX_PANE || !hooksInstalled) return;
		await Promise.allSettled([
			runTmux(["set-hook", "-up", "-t", TMUX_PANE, `pane-focus-in[${HOOK_ID}]`]),
			runTmux(["set-hook", "-up", "-t", TMUX_PANE, `pane-focus-out[${HOOK_ID}]`]),
		]);
		hooksInstalled = false;
	}

	async function startWatching(): Promise<void> {
		if (!STATE_FILE || stateWatcher) return;
		stateWatcher = watch(STATE_FILE, { persistent: false }, () => {
			void applyStateFromFile();
		});
		stateWatcher.on("error", () => {
			stateWatcher?.close();
			stateWatcher = undefined;
		});
	}

	async function stopWatching(): Promise<void> {
		stateWatcher?.close();
		stateWatcher = undefined;
		if (!STATE_FILE) return;
		await rm(STATE_FILE, { force: true });
	}

	async function startMonitoring(): Promise<void> {
		if (!TMUX_PANE || !STATE_FILE) return;
		await installHooks();
		await startWatching();
		await applyStateFromFile();
	}

	async function stopMonitoring(): Promise<void> {
		await uninstallHooks();
		await stopWatching();
	}

	function installEditor(ctx: ExtensionContext): void {
		if (!TMUX_PANE) return;
		ctx.ui.setEditorComponent((tui, theme, keybindings) => {
			const editor = new TmuxPaneAwareEditor(tui, theme, keybindings);
			editor.setTmuxPaneFocused(isTmuxPaneFocused);
			currentEditor = editor;
			setTimeout(() => wireExitCleanupHandlers(editor), 0);
			return editor;
		});
	}

	function wireExitCleanupHandlers(editor: TmuxPaneAwareEditor): void {
		const anyEditor = editor as TmuxPaneAwareEditor & {
			__exitCleanupWired?: boolean;
			onCtrlD?: () => void;
			actionHandlers?: Map<string, () => void>;
		};
		if (anyEditor.__exitCleanupWired) return;
		anyEditor.__exitCleanupWired = true;

		const originalCtrlD = anyEditor.onCtrlD;
		anyEditor.onCtrlD = () => {
			if (editor.getText().length === 0) {
				editor.prepareForExit();
				setTimeout(() => originalCtrlD?.(), 20);
				return;
			}
			originalCtrlD?.();
		};

		const originalClear = anyEditor.actionHandlers?.get("app.clear");
		if (originalClear) {
			anyEditor.actionHandlers?.set("app.clear", () => {
				if (editor.getText().length === 0) {
					editor.prepareForExit();
					setTimeout(() => originalClear(), 20);
					return;
				}
				originalClear();
			});
		}
	}

	pi.on("session_start", async (_event, ctx) => {
		if (!ctx.hasUI || !TMUX_PANE) return;
		installEditor(ctx);
		await startMonitoring();
	});

	pi.on("session_switch", async (_event, ctx) => {
		if (!ctx.hasUI || !TMUX_PANE) return;
		installEditor(ctx);
		await startMonitoring();
	});

	pi.on("session_shutdown", async () => {
		currentEditor = null;
		await stopMonitoring();
	});
}
