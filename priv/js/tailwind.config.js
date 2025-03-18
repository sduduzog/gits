const colors = {
	"waikawa-gray": {
		base: "#5D6A96",
		50: "#F7F8FA",
		100: "#CED2E0",
		200: "#A6ADC5",
		300: "#7D88AB",
		400: "#58658F",
		500: "#4D587D",
		600: "#424B6B",
		700: "#373F59",
		800: "#2C3247",
		900: "#212535",
		950: "#151823",
	},
};

/** @type {import('tailwindcss').Config} */
module.exports = {
	presets: [require("tailwindcss-preset-email")],
	content: ["./components/**/*.html", "./templates/**/*.html"],
	theme: {
		extend: {
			fontFamily: {
				poppins: [
					"Poppins",
					"ui-sans-serif",
					"system-ui",
					"-apple-system",
					'"Segoe UI"',
					"sans-serif",
				],

				"open-sans": [
					"Open Sans",
					"ui-sans-serif",
					"system-ui",
					"-apple-system",
					'"Segoe UI"',
					"sans-serif",
				],
			},
			colors: {
				zinc: {
					50: "#f4f5f7",
					100: "#e4e5e9",
					200: "#cbcdd6",
					300: "#a7aab9",
					400: "#7b7f95",
					500: "#60637a",
					600: "#525468",
					700: "#474957",
					800: "#3f3f4b",
					900: "#383941",
					950: "#09090b",
				},
				brand: {
					base: "#BD1A55",
					50: "#fdf2f7",
					100: "#fce7f2",
					200: "#fbcfe6",
					300: "#f8a9d0",
					400: "#f373af",
					500: "#ea4a90",
					600: "#d9296e",
					700: "#bd1a55",
					800: "#9b1946",
					900: "#82193d",
					950: "#4f0820",
				},
				primary: colors["waikawa-gray"],
			},
		},
	},
};
