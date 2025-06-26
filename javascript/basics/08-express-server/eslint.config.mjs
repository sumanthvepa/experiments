import js from "@eslint/js";
import globals from "globals";
import json from "@eslint/json";
import { defineConfig } from "eslint/config";


export default defineConfig([
  {
    files: ["**/*.{js,mjs,cjs}"],
    plugins: { js },
    extends: ["js/recommended"],
    languageOptions: {
      ecmaVersion: 2024,
    }
  },
  { files: ["**/*.{js,mjs,cjs}"], languageOptions: { globals: globals.node } },
  { 
    files: ["**/*.json"],
    plugins: { json },
    language: "json/json",
    extends: ["json/recommended"] },
    // This is manually added
    ignores: [
      "**/node_modules/**",
      "**/dist/**",
      "**/build/**",
      "**/coverage/**",
      "package-lock.json",
      "yarn.lock",
      "pnpm-lock.yaml"
    ]
]);
