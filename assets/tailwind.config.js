import plugin from "tailwindcss/plugin";
import { readdirSync, readFileSync } from "node:fs";
import { join, basename } from "node:path";

import { addIconSelectors, addDynamicIconSelectors } from "@iconify/tailwind";

const content = [
  "./js/**/*.js",
  "../lib/gits_web.ex",
  "../lib/gits_web/**/*.*ex",
  "../lib/gits_web/**/*.html",
];
const theme = {
  extend: {
    fontFamily: {
      poppins: ["Poppins", "sans-serif"],
      "open-sans": ["Open Sans Variable", "sans-serif"],
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
    },
  },
};

const plugins = [
  require("@tailwindcss/forms"),
  addDynamicIconSelectors({ scale: 1.25 }),

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
];

export default {
  content,
  theme,
  plugins,
};
