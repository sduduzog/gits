import { render } from "@maizzle/framework";
import fs from "node:fs/promises";
import path from "node:path";

export async function render_template(
	templateName,
	baseUrl,
	title,
	preheader,
	locals,
) {
	process.chdir(import.meta.dirname);
	const templatePath = path.join(
		process.cwd(),
		`templates/${templateName}.html`,
	);
	const templateContent = await fs.readFile(templatePath, "utf8");
	const { html } = await render(templateContent, {
		baseURL: baseUrl,
		title: title,
		preheader: preheader,
		css: {
			inline: true,
			purge: true,
			shorthand: true,
		},
		prettify: true,
		locals,
	});
	return html;
}
