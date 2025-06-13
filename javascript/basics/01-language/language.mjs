//-*- coding: utf-8 -*-
/**
 * @file language.mjs: A series of notes on the Javascript programming
 * language, written as a collection of Javascript modules and files.
 * @author Sumanth Vepa <svepa@milestone42.com>
 * @license GNU General Public License v3.0
 */
/* -------------------------------------------------------------------
 * language.mjs: A series of notes on the Javascript programming
 * language, written as a collection of Javascript modules and files.
 *
 * Copyright (C) 2024-25 Sumanth Vepa.
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see
 * <https://www.gnu.org/licenses/>.
 -------------------------------------------------------------------*/

// This project consists of a series of tutorial notes on the
// Javascript programming language. This file: language.mjs is the
// entry point into all the explorations.

// The notes are written as a series of Javascript modules. Each module
// explores a specific feature of the Javascript language. The modules
// are organized as follows:
// 00-comments.mjs: Explore comments in Javascript
// 01-hello.js: Print 'Hello, World!' on the console.
// 02-printing.mjs: Explore printing in Javascript
// 03-const.mjs: Explore the intricacies of constants
// 04-let.mjs: Explore the let keyword
// 05-vars.mjs: Explore the var keyword
// 06-implicit-globals.js: Explore implicit globals
// 07-dynamic-typing.mjs: Explore dynamic typing
// 08-number.mjs: Explore numbers in Javascript
// 09-strings.mjs: Explore strings in Javascript
// 10-boolean.mjs: Explore booleans in Javascript
// 11-regexp.mjs: Explore regular expressions in Javascript
// 12-null-and-undefined.mjs: Explore null and undefined in Javascript
// 13-type-conversions.mjs: Explore type conversions in Javascript
// 14-comparisons.mjs: Explore comparisons in Javascript
// 15-control-flow.mjs: Explore control flow
// 16-functions.mjs: Explore functions in Javascript
// 17-objects-and-classes.mjs: Explore objects and classes
// 18-enumerations.mjs: Explore enumerations
// 19-callbacks.mjs: Explore callbacks
// 20-promises.mjs: Explore promises
// 21-async-await.mjs: Explore async/await

// For more information on the Javascript programming language, see the following
// references:
// 1. https://javascript.info/
// 2. https://developer.mozilla.org/en-US/docs/Web/JavaScript/

// A note on the coding comment at the top of files.
// The coding comment at the top of the file is a convention used to
// indicate the character encoding of the file. The coding comment
// is not a Javascript feature. It is a convention used by text
// editors and other tools to determine the character encoding of
// the file. I use utf-8 as the character encoding for all my files.
// The coding comment is not necessary for Javascript files, but I
// include it as a matter of habit.


// A note on imports.
// All the import statements in this file are executed first regardless
// of their position in the file. This is because the Javascript
// module system is synchronous. This means that the imports are
// executed before the rest of the code in the file, in the order
// in which they occur in the file.

// For this code, it only matters that the code associated with the
// import occurs after the corresponding import statement. There is
// no dependency between Note blocks. So, the fact that all the imports
// are executed first before any of the code in this file does not really
// matter. So the import statement is placed closest to where it is used.
// However, in a more complex project, this could cause much confusion.
// In general, it is a good idea to place all the imports at the top of
// the file.

// A note on types of imports.
// As a general rule of thumb, I use ES56 import statements
// for all my imports, rather than the older CommonJS require()
// statements.

// There are two types of imports in ES6:
// 1. Default imports: These are imported without curly braces.
//    A module can have only one default export, but it can have
//    multiple named exports.
// For example the code blow import anImportableFunction from 02-imports-and-exports.mjs

import anImportableFunction from './02-imports-and-exports.mjs';
anImportableFunction()

// 2. Named imports: These are imported with curly braces.
//    A module can have multiple named exports, but only one default
//    export.
//    Named exports are useful when you want to export
//    multiple values from a module, while default exports are useful
//    when you want to export a single value from a module.

// A note on the .mjs extension and "type": "module" in package.json
// The .mjs extension is used to indicate that a file is a Javascript
// module. This is the rule that Node.js uses to distinguish modules
// from regular Javascript files.
// One can also designate all files in a Node.js project to be modules
// by setting "type": "module" in package.json.
// I usually do both. But NOT for this project. Some features that I
// want to explore (e.g. implicit globals) are not available in
// 'strict' mode. Since modules automatically enable strict mode, I am
// not using the "type": "module" entry which will make all files
// modules, regardless of the .mjs extension.

// A Note on Javascript coding style
// I use the Google Javascript style guide for my code.
// https://google.github.io/styleguide/jsguide.html

// A note on suppressing ESLint and IntelliJ IDEA warnings.
// These show up as a comment before the code that is causing the
// warning. The comment will have the word 'noinspection' followed by
// the warning code. For example, 'noinspection ES6ConvertVarToLetConst'
// These suppress warnings from IntelliJ IDEA's linter for the next
// statement. They should generally be avoided in production quality
// code, unless they really are necessary. But are used in these
// tutorial explorations extensively, because the code is often
// deliberately written to trigger warnings. Their presence is an
// indication that I am aware of the fact that the code is not
// good style, but that I suppressed the warnings to avoid cluttering
// the problems tab of IntelliJ.
// You can get a complete list of noinspection comment values here:
// https://gist.github.com/pylover/7870c235867cf22817ac5b096defb768

// Note 0: Explore comments in Javascript
import { exploreComments } from './00-comments.mjs'
exploreComments();

// Note1: Print 'Hello, World!' on the console.
import './01-hello.js';

// Note 2: Explore imports and exports
// There are two types of imports in ES6:
// 1. Default imports: These are imported without curly braces.
// 2. Named imports: These are imported with curly braces.

// Note that no curly braces are used for the default import.
// Also, not that the path to the module is specified relative to the
// location of this file. Note that any file modules must be imported
// with a path.
import defaultExportedFunction from './02-imports-and-exports.mjs';
defaultExportedFunction();

// You can use any name for the default import. It does not have to
// match the name of the exported function in the module.
// Notice that we've imported the same function twice, once as
// defaultExportedFunction and once as theDefaultExportedFunction.
// We would not typically do this in production code, but we do it
// here to demonstrate the that you can import a default export
// using any name you like, and that the name does not have to match
// the name of the exported function in the module.
import theDefaultExportedFunction from './02-imports-and-exports.mjs';
theDefaultExportedFunction();

// Named imports are imported with curly braces. Unlike, you have to use
// the exact name of the exported function in the module when you
// import it.
import { namedExportedFunction1 } from './02-imports-and-exports.mjs';
namedExportedFunction1()

// You can import multiple named exports from a module using a single
import { namedExportedFunction2, namedExportedFunction3 } from './02-imports-and-exports.mjs';
namedExportedFunction2();
namedExportedFunction3()

// You can change the name of a named import using the 'as' keyword.
// Although you must refer to name of the function as it is specified
// in the module when you alias it.
import { namedExportedFunction4 as renamedFunction } from './02-imports-and-exports.mjs';
renamedFunction();

// You can import from npm packages that you have installed in your
// project. For example, the 'lodash' package is a popular utility
// library that provides a lot of useful functions for working with
// arrays, objects, and other data types. You can install it using
// npm install lodash and then import it in your code.
// To add it to you package.json file, you can use the command:
// npm install --save lodash. This will add lodash to the
// dependencies section of your package.json file. Always do this when
// you install a package using npm. This way, the package will be
// automatically installed when you run npm install in your project.
// Otherwise, the import will fail when you try to run your code after
// fresh checkout of the project from a version control system.
// noinspection ES6UnusedImports

// Also note the use of _ as the name of the imported module.
// This is a common convention in the Javascript community for
// importing the lodash library. It is not a requirement, but it is
// a widely used convention. '_' is a valid identifier in Javascript,
import _ from 'lodash';

// You can import from built-in modules as well.
// noinspection ES6UnusedImports
import { readFileSync } from 'fs';

// It is recommended to specify that you are importing from a builtin
// module provided by Node.js. This prevents the built-in module from
// being confused with a local or npm installed module of the same name.
// This is done by using the 'node:' prefix in the import statement.
// Note the use of 'node:' prefix in the import statement.
// noinspection ES6UnusedImports
import { readFileSync as readFileSyncFromNode } from 'node:fs';

// You can import submodules from a module as well.
// noinspection ES6UnusedImports
import { readFile as readFilePromisesFromNodeSubmodule } from 'node:fs/promises';

// Note2: Explore printing in Javascript
import { explorePrinting } from './02-printing.mjs';
explorePrinting()

// Note 3: Explore the intricacies of constants
// DAYS_PER_WEEK is a default import hence the lack of curly braces
import DAYS_PER_WEEK from './03-const.mjs';
// HOLIDAYS is a named import hence the curly braces
// A module can have multiple named exports but only one default export
import { HOLIDAYS } from './03-const.mjs';
console.log('DAYS_PER_WEEK:', DAYS_PER_WEEK);
console.log('HOLIDAYS:', HOLIDAYS);


// Note 4: Explore the let keyword
import { exportedVariable, modifyExportedVariable } from './04-let.mjs';
console.log('exportedVariable:', exportedVariable); // 40
// exportedVariable cannot be changed directly.
// exportedVariable = 27; // TypeError: Assignment to constant variable.
// But it can be modified indirectly.
modifyExportedVariable(27);
console.log('exportedVariable:', exportedVariable); // 27

// Note 5: Explore the var keyword
import { f1, f2, f3, f4 } from './05-vars.mjs';
f1();
f2();
f3();
f4();

// Note 6: Explore implicit globals
console.log(anImplicitGlobal); // Yup, because imports are processed
                               // first, the implicit global is
                               // available even before the import
                               // statement. Don't use implicit globals!
import './06-implicit-globals.js';
console.log(anImplicitGlobal); // defined in 06-implicit-globals.js:f1()
                               // but is available everywhere without
                               // an import.

// Note 7: Explore dynamic typing
import './07-dynamic-typing.mjs';

// Note 8: Explore numbers in Javascript
import { exploreNumbers} from './08-number.mjs';
exploreNumbers();

// Note 9: Explore strings in Javascript
import { exploreStrings } from './09-strings.mjs';
exploreStrings()

// Note 10: Explore booleans in Javascript
import { taskCompleted, completeTask } from './10-boolean.mjs';
if (!taskCompleted) {
  completeTask();
}
console.log('taskCompleted:', taskCompleted); // true

// Note 11: Explore regular expressions in Javascript
import { exploreRegexps} from './11-regexp.mjs';
exploreRegexps();

// Note 12: Explore null and undefined in Javascript
import { exploreNullAndUndefined } from './12-null-and-undefined.mjs';
exploreNullAndUndefined();

// Note 13: Explore type conversions in Javascript
import { exploreTypeConversion } from './13-type-conversions.mjs';
exploreTypeConversion();


// Note 14: Explore comparisons in Javascript
import { exploreComparisons } from './14-comparisons.mjs';
exploreComparisons();

// Note 15: Explore control flow
import { exploreControlFlow } from './15-control-flow.mjs';
exploreControlFlow();

// Note 16: Explore functions in Javascript
import { exploreFunctions } from './16-functions.mjs';
exploreFunctions();

// Note 17: Explore objects and classes
import {
  exploreObjects,
  exploreClasses,
  exploreObjectInheritance,
  exploreConstructorFunctionBasedClasses,
  exploreClassInheritance
} from './17-objects-and-classes.mjs';
exploreObjects();
exploreObjectInheritance();
exploreConstructorFunctionBasedClasses();
exploreClasses();
exploreClassInheritance();

// Note 18: Explore enumerations
import { exploreEnumerations } from "./18-enumerations.mjs";
exploreEnumerations();

// Note 19: Explore callbacks
import { exploreCallbacks } from "./19-callbacks.mjs";
exploreCallbacks();

// Note 20: Explore promises
import { explorePromises } from "./20-promises.mjs";
explorePromises();

import {
  exploreAsyncAwait,
  exploreCallingAsyncFunctionsFromWithinNonAsyncFunctions } from "./21-async-await.mjs";
await exploreAsyncAwait();
// Call a non-async function that calls an async function
exploreCallingAsyncFunctionsFromWithinNonAsyncFunctions();

// TODO: Explore exceptions