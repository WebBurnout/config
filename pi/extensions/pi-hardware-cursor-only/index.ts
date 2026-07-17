import {
	CustomEditor,
	type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";
import { CURSOR_MARKER } from "@earendil-works/pi-tui";

function stripSoftwareCursor(line: string): string {
	const markerIndex = line.indexOf(CURSOR_MARKER);
	if (markerIndex === -1) return line;

	const cursorStart = markerIndex + CURSOR_MARKER.length;
	if (!line.startsWith("\x1b[7m", cursorStart)) return line;

	const contentStart = cursorStart + "\x1b[7m".length;
	const resetAllIndex = line.indexOf("\x1b[0m", contentStart);
	const resetInverseIndex = line.indexOf("\x1b[27m", contentStart);
	const resetIndex = [resetAllIndex, resetInverseIndex]
		.filter((index) => index !== -1)
		.sort((first, second) => first - second)[0];
	if (resetIndex === undefined) return line;

	const resetLength = line.startsWith("\x1b[0m", resetIndex)
		? "\x1b[0m".length
		: "\x1b[27m".length;
	const cursorContent = line.slice(contentStart, resetIndex);

	return (
		line.slice(0, cursorStart) +
		cursorContent +
		line.slice(resetIndex + resetLength)
	);
}

class HardwareCursorEditor extends CustomEditor {
	render(width: number): string[] {
		return super.render(width).map(stripSoftwareCursor);
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, context) => {
		if (!context.hasUI) return;
		context.ui.setEditorComponent(
			(terminalInterface, theme, keybindings) =>
				new HardwareCursorEditor(
					terminalInterface,
					theme,
					keybindings,
				),
		);
	});
}
