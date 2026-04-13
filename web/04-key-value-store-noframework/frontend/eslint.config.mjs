import js from "@eslint/js";
import globals from "globals";
import json from "@eslint/json";
import markdown from "@eslint/markdown";
import css from "@eslint/css";
import {defineConfig} from "eslint/config";


export default defineConfig([
  {
    files: ["**/*.{js,mjs,cjs}"],
    plugins: {js}, extends: ["js/recommended"],
    languageOptions: {
      ecmaVersion: 2024,
      sourceType: "module",
      globals: globals.node,
    },
    ignores: [
      "**/node_modules/**",
      "**/dist/**",
      "**/build/**",
      "**/coverage/**",
    ]
  },
  {
    files: ["**/*.{js,mjs,cjs}"],
    languageOptions: {
      globals: globals.browser
    },
    ignores: [
      "**/node_modules/**",
      "**/dist/**",
      "**/build/**",
      "**/coverage/**"
    ]
  },
  {
    files: ["**/*.json"],
    plugins: {json},
    language: "json/json",
    extends: ["json/recommended"],
    ignores: [
      "**/node_modules/**",
      "**/dist/**",
      "**/build/**",
      "**/coverage/**",
      "package-lock.json",
      "yarn.lock",
      "pnpm-lock.yaml"
    ]
  },
  {
    files: ["**/*.md"],
    plugins: {markdown},
    language: "markdown/gfm",
    extends: ["markdown/recommended"],
    ignores: [
      "**/node_modules/**",
      "**/dist/**",
      "**/build/**",
      "**/coverage/**"
    ]
  },
  {
    files: ["**/*.css"],
    plugins: {css},
    language: "css/css",
    extends: ["css/recommended"],
    ignores: [
      "**/node_modules/**",
      "**/dist/**",
      "**/build/**",
      "**/coverage/**"
    ]
  },
]);
