import { defineConfig, loadEnv } from "vite";
import tailwindcss from "tailwindcss";
import autoprefixer from "autoprefixer";
import process from "node:process";

import Unfonts from "unplugin-fonts/vite";

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), "");
  return {
    publicDir: false,
    plugins: [
      Unfonts({
        fontsource: {
          families: [
            {
              name: "Poppins",
              weights: [100, 200, 300, 400, 500, 600, 700, 800, 900],
            },
          ],
        },
      }),
    ],
    build: {
      outDir: "../priv/static",
      emptyOutDir: false,
      target: ["es2020"],
      manifest: false,
      rollupOptions: {
        input: "js/app.js",
        output: {
          assetFileNames: "assets/[name][extname]",
          chunkFileNames: "[name].js",
          entryFileNames: "assets/[name].js",
        },
      },
      commonjsOptions: {
        exclude: [],
        include: ["vendor/topbar.js"],
      },
    },
    css: {
      postcss: {
        plugins: [tailwindcss, autoprefixer],
      },
    },
    define: {
      __APP_ENV__: env.APP_ENV,
    },
  };
});
