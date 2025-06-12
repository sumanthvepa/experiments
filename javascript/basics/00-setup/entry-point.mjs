/* -------------------------------------------------------------------
 * 00a-setup.mjs: A dummy file for use in a demonstration of setting
 * up a node project using npm.
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


// A note on comments
// The comments for programs in this series are intended to be read
// as teaching notes rather than as standard comments. They are far
// more extensive than typical comments, as they are intended
// for educational purposes. Real code would be commented differently.
// Read the comments alongside the code to get the most out of them.


// This part of a sample project that demonstrates how to set up
// a node project. See the README.md file for complete instructions.


// Import various modules.
// See 00-server for an explanation of how ES6 imports work and
// why they should be preferred over the commonJS require.
// In this context the imports serve no real purpose.

// Note on noinspection comments
// These suppress warnings from IntelliJ IDEA's linter. They are
// not necessary in a real program, but are used here to avoid
// cluttering the code with warnings.

// noinspection ES6UnusedImports
import http from 'node:http';
// noinspection ES6UnusedImports
import { Command } from 'commander';
// noinspection ES6UnusedImports
import express from 'express';

// Just some sample text 
console.log('Sample program for the setup project');
