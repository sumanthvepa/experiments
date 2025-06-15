import js from "@eslint/js";
import globals from "globals";
import json from "@eslint/json";
import { defineConfig } from "eslint/config";

// Enabling ESLLint on a fresh project
// To enable ESLint on a fresh project, you can run the following
// command in the terminal in the root directory of your project:

// npm init @eslint/config@latest

// This will prompt you to answer a few questions about your project
// and then create a file called eslint.config.mjs in the root
// directory of your project. This file contains the configuration
// for ESLint.

// Here are the questions that you will be prompted to answer:
// 1. What do you want to lint? (You can choose to lint JavaScript,
//  JSON, JSON with comments, JSONS, Markdown and CSS)
// Always, choose JavaScript, and then choose any of the others
// depending on your project. For this project, I chose JavaScript
// and JSON.
// The text interface is a bit confusing, but you can choose
// multiple options by using the arrow keys to navigate and the
// space bar to select the options you want. You can also use
// the 'a' key to select all options, or the 'i' key to invert
// the selection. Press Enter to continue after making your
// selection.
//
// 2. How would you like to use ESLint? You can choose to
// check syntax only, or check syntax and find problems. It's
// recommended to choose the second option.
//
// 3. What type of modules does your project use? You can choose
// between JavaScript modules, CommonJS, or None. I always use
// JavaScript modules, so I chose that option.
//
// 4. Which framework does your project use? You can choose
// between React, Vue.js, or None. I chose None for this project,
// since it is a simple project that does not use any framework.
//
// 5. Does your project use TypeScript? You can choose Yes or No.
// I chose No for this project, since it is a pure JavaScript project
// that does not use TypeScript.
//
// 6. Where does your code run? You can choose Browser and/or Node.js.
// Pick both options if you are writing code that runs in both
// environments. For this project, I chose Node.js, since it is a
// Node.js project that runs in the terminal.
//
// 7. Would you like to install them now? You can choose Yes or No.
// I chose Yes, since I want to install the necessary dependencies
//
// 8. Which package manager would you like to use? I use npm, so I
// chose npm.
//
// After getting answer to these questions, ESLint will install the
// necessary npm packages and update your package.json and
// package-lock.json files. ESLint dependencies are usually added as
// dev dependencies. It also creates file called eslint.config.mjs
// in the root directory of your project. This file contains the
// initial configuration for ESLint.

// This file will need to be modified to ignore certain files,
// to specify the version of ECMAScript (Javascript) that you are
// using, specify that you are using modules, and to specify the
// environment in which your code runs (e.g. Node.js or Browser).

// To do this you can edit the eslint.config.mjs file and add the
// following configuration. It should be added to the first dictionary
// in the list passed to the 'defineConfig' function.
// ```javascript
// import globals from "globals";
// languageOptions: {
//   ecmaVersion: 2024,
//   sourceType: "module",
//   globals: globals.node
// },
// ignores: [
//   "**/node_modules/**",
//   "**/dist/**",
//   "**/build/**",
//   "**/coverage/**"
// ],
// ``
// See eslint.config.mjs for explanation of the above configuration.
// I'd recommend that you check the differences between the generated
// eslint.config.mjs file and the one in this project, so that you
// understand what the configuration does.

// Note that you might get an error when you run ESLint somtimes
// indicating that the 'globals' module is not found. This is because
// the 'globals' module is not installed by default. You can install it
// using the following command: npm install --save-dev globals.
// Then you can import it in your eslint.config.mjs file (see above).

// Now you can run ESLint from the terminal using npx.
// npx is a command that runs a binary from local node_modules.
// It is installed as part of npm, so you don't need to install it
// separately. You can run ESLint using the following command:
// npx eslint .
// This will run ESLint on all the files in your project and
// display any linting errors or warnings in the terminal.

// Enabling ESLint in IntelliJ IDEA
// To enable ESLint in IntelliJ IDEA, you need to go to
// Preferences > Languages & Frameworks > JavaScript > Code Quality
// Tools > ESLint and select the 'Automatic ESLint configuration'
// option. This will enable ESLint in your project and IntelliJ IDEA
// will automatically detect the eslint.config.mjs file and use it
// to lint your code.

export default defineConfig([
  {
    // These are linting rules for JavaScript files.
    files: ["**/*.{js,mjs,cjs}"],
    plugins: { js },
    extends: ["js/recommended"],
    // This is added manually after npm init @eslint/config@latest
    languageOptions: {
      ecmaVersion: 2024, // This tells ESLint to check for the ES2024 features
                         // (this is the latest version as of June 2025)
      sourceType: "module", // This tells ESLint it will check ES modules
      globals: globals.node, // This tells ESLint that the environment is Node.js
    },
    // This is also added manually after npm init @eslint/config@latest
    // These are the files and directories that ESLint should ignore
    // when linting javascript files.
    ignores: [
      "**/node_modules/**",
      "**/dist/**",
      "**/build/**",
      "**/coverage/**"
    ],
  },
  {
    // These are linting rules for JSON files.
    files: ["**/*.json"],
    plugins: { json },
    language: "json/json",
    extends: ["json/recommended"],
    // This is also added manually after npm init @eslint/config@latest
    // These are the files and directories that ESLint should ignore
    // In particular, we ignore package-lock.json as it has some
    // non-standard entries that ESLint does not like.
    ignores: [
      "**/node_modules/**",
      "**/dist/**",
      "**/build/**",
      "**/coverage/**",
      "package-lock.json",
      "yarn.lock",
      "pnpm-lock.yaml"
    ],
  },
]);
