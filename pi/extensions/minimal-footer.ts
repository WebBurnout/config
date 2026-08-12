import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { isAbsolute, relative, resolve, sep } from "node:path";

const WARN_TOKENS = 200_000;
const ERROR_PERCENT = 90;

function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1000000) return `${Math.round(count / 1000)}k`;
	if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
	return `${Math.round(count / 1000000)}M`;
}

function formatCwd(cwd: string, home: string | undefined): string {
	if (!home) return cwd;
	const relativeToHome = relative(resolve(home), resolve(cwd));
	const isInsideHome = relativeToHome === "" ||
		(relativeToHome !== ".." && !relativeToHome.startsWith(`..${sep}`) && !isAbsolute(relativeToHome));
	if (!isInsideHome) return cwd;
	return relativeToHome === "" ? "~" : `~${sep}${relativeToHome}`;
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		ctx.ui.setFooter((tui, theme, footerData) => {
			const unsubscribe = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose: unsubscribe,
				invalidate() {},
				render(width: number): string[] {
					let pwd = formatCwd(ctx.sessionManager.getCwd(), process.env.HOME || process.env.USERPROFILE);
					const branch = footerData.getGitBranch();
					if (branch) pwd = `${pwd} (${branch})`;
					const sessionName = ctx.sessionManager.getSessionName();
					if (sessionName) pwd = `${pwd} • ${sessionName}`;

					const contextUsage = ctx.getContextUsage();
					const contextWindow = contextUsage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
					const tokens = contextUsage?.tokens ?? null;
					const percent = contextUsage?.percent ?? null;
					const left = tokens === null || percent === null
						? theme.fg("dim", `?/${formatTokens(contextWindow)}`)
						: theme.fg(
							percent > ERROR_PERCENT ? "error" : tokens > WARN_TOKENS ? "warning" : "dim",
							`${formatTokens(tokens)}/${formatTokens(contextWindow)} ${percent.toFixed(1)}%`,
						);

					const modelName = ctx.model?.id || "no-model";
					let right = ctx.model?.reasoning
						? `${modelName} • ${ctx.thinkingLevel === "off" || !ctx.thinkingLevel ? "thinking off" : ctx.thinkingLevel}`
						: modelName;
					if (footerData.getAvailableProviderCount() > 1 && ctx.model) {
						const withProvider = `(${ctx.model.provider}) ${right}`;
						if (visibleWidth(left) + 2 + visibleWidth(withProvider) <= width) right = withProvider;
					}

					const padding = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(right)));
					const lines = [
						truncateToWidth(theme.fg("dim", pwd), width, theme.fg("dim", "...")),
						truncateToWidth(left + theme.fg("dim", padding + right), width, theme.fg("dim", "...")),
					];

					const statuses = footerData.getExtensionStatuses();
					if (statuses.size > 0) {
						const statusLine = Array.from(statuses.entries())
							.sort(([a], [b]) => a.localeCompare(b))
							.map(([, text]) => text.replace(/[\r\n\t]/g, " ").replace(/ +/g, " ").trim())
							.join(" ");
						lines.push(truncateToWidth(statusLine, width, theme.fg("dim", "...")));
					}

					return lines;
				},
			};
		});
	});
}
