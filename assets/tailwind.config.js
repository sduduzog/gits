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
      anakiwa: {
        50: "#FAFCFF",
        100: "#E3EBFE",
        200: "#CBDAFD",
        300: "#B4C9FD",
        400: "#99B3EF",
        500: "#869CD1",
        600: "#7285B3",
        700: "#5F6F95",
        800: "#4C5876",
        900: "#384258",
        950: "#252B3A",
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
      "red-violet": {
        base: "#C51566",
        50: "#FCF3F7",
        100: "#EEB9D1",
        200: "#DF7EAB",
        300: "#D14485",
        400: "#BB1461",
        500: "#A41155",
        600: "#8C0F48",
        700: "#740C3C",
        800: "#5D0A30",
        900: "#450724",
        950: "#2D0517",
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
