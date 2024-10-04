import plugin from "tailwindcss/plugin";
import { readdirSync, readFileSync } from "node:fs";
import { join, basename } from "node:path";

const content = [
	"./js/**/*.js",
	"../lib/gits_web.ex",
	"../lib/gits_web/**/*.*ex",
	"../lib/gits_web/**/*.html",
];
 const theme = {
	extend: {
		fontFamily: {
			inter: ["Inter", "sans-serif"],
			poppins: ["Poppins", "sans-serif"],
		},
		colors: {
			brand: "#ee0290",
		},
	},
};

const plugins = [
	require("@tailwindcss/forms"),
	// Allows prefixing tailwind classes with LiveView classes to add rules
	// only when LiveView classes are applied, for example:
	//
	//     <div class="phx-click-loading:animate-ping">
	//
	plugin(({ addVariant }) =>
		addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"]),
	),
	plugin(({ addVariant }) =>
		addVariant("phx-click-loading", [
			".phx-click-loading&",
			".phx-click-loading &",
		]),
	),
	plugin(({ addVariant }) =>
		addVariant("phx-submit-loading", [
			".phx-submit-loading&",
			".phx-submit-loading &",
		]),
	),
	plugin(({ addVariant }) =>
		addVariant("phx-change-loading", [
			".phx-change-loading&",
			".phx-change-loading &",
		]),
	),

	plugin(({ matchComponents, theme }) => {
		const iconsDir = join(__dirname, "../deps/heroicons/optimized");
		const values = {};
		const icons = [
			["", "/24/outline"],
			["-solid", "/24/solid"],
			["-mini", "/20/solid"],
			["-micro", "/16/solid"],
		];
		for (const [suffix, dir] of icons) {
			for (const file of readdirSync(join(iconsDir, dir))) {
				const name = basename(file, ".svg") + suffix;
				values[name] = { name, fullPath: join(iconsDir, dir, file) };
			}
		}
		matchComponents(
			{
				hero: ({ name, fullPath }) => {
					const content = readFileSync(fullPath)
						.toString()
						.replace(/\r?\n|\r/g, "");
					let size = theme("spacing.6");
					if (name.endsWith("-mini")) {
						size = theme("spacing.5");
					} else if (name.endsWith("-micro")) {
						size = theme("spacing.4");
					}
					return {
						[`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
						"-webkit-mask": `var(--hero-${name})`,
						mask: `var(--hero-${name})`,
						"mask-repeat": "no-repeat",
						"background-color": "currentColor",
						"vertical-align": "middle",
						display: "inline-block",
						width: size,
						height: size,
					};
				},
			},
			{ values },
		);
	}),
];

export default {
  content,
  theme,
  plugins
}
