# Creating and Managing a Node.js/NPM Project
This project and file describes how to set up a simple Node.js project.

## Install NodeJS and NPM
### Installation Instructions for macOS
The first step is to ensure that you've installed node and npm on your
system.

On macOS using MacPorts. Note that nn is a placeholder for the version
of node you want to install.
```
  sudo port install nodejsNN 
```

Replace NN with the actual node version you want to install For
example:
```
  sudo port install nodejs22
```

I tend to stick with LTS releases of node rather than live  on the
bleeding edge.
  
Then install npm the node package manager
  sudo port install npmNN
Replace npm with the latest version of npm.
For example:
```
  sudo port install npm11
```

### AlmaLinux setup instructions
Check to see if Node.js 20 is available
```
  dnf -y module list nodejs
```
Make sure other version of Node.js are disabled
```
  dnf -y module reset nodejs
  dnf -y module enable nodejs:22
```

Install nodejs:20
```
  dnf -y module install nodejs:20/common
```

### Alternative instructions for containers

For detailed instructions on installing Node.js in a container
see /docker/basics/10-docker-build-node.sh
and /docker/basics/11-docker-build-node-optimized.

## First Time Setup
The following instructions are for first time setup. i.e. when  you
are creating the project. If you've checked out an existing project
that already has a package.json file, see  section on setting up an
existing project.

## Initialize npm for the project
You can find a good tutorial for this at
[Node Source](https://nodesource.com/blog/an-absolute-beginners-guide-to-using-npm/).
```
  npm init
```

## Install Project Dependencies
Then install project dependencies. For this project we are going to
install commander and express.
```
  npm install commander
  npm install express
```

If a package is only needed during development (for example:
a test framework), then install it as follows:
```
  npm install --save-dev mocha
```

This will create a package.json and package-lock.json.
See Appendix A for more information on how these files work.

It may also create a node_modules folder that will contain
node modules. 

You should check in package.json and package-lock.json
into source code control, and ignore node_modules (i.e.
add it to .gitignore.)

## Add support for ES6 imports
Edit package.json to add the following lines:
Below the main entry:

```
  "type": "module",
```

This will treat the entry point file as a module file. You can
also achieve this by having a .mjs extension to the file.
I typically do both, although that is unnecessary.

I prefer Javascript modules, as they enforce certain
things that make life easier for large scale development.

## Preparing the package for running
Then proceed to create the package entry point file
with the code you want to run. It's called entry-point.mjs
in this project.

You then tell npm which scripts it can run in your project,
by adding an entry to the scripts dictionary in packages.json

For example, you can create a key named 'entry-point' which
invokes the entry-point.mjs script using node:
```
  "scripts": {
    "entry-point": "node entry-point.mjs"
  }
```
Note you may have to add a comma at the end of the line,
if there are other scripts in the scripts section.

This tells npm that there is a program named 'entry-point'
that can be run using npm. The value of the key 'entry-point',
provides the shell command needed to run the program.

Note that although we gave the key the same name (entry-point) as 
the script's filename (entry-point.mjs), there is no necessity to
do that. You can pick any name you like for the program name key.
For example this is perfectly fine:
```
  "scripts": {
    "myapp": "node entry-point.mjs"
  }
```

In this case, the name of the program that is used when issuing the
npm run command would be 'myapp'.

For web servers, it is traditional to call the primary script 'start'.
This is a special script name that you  can invoke directly without
using 'run'. See below  for a more detailed explanation.

## Running the program
There are several ways to run this program in this project:

### Option 1: Run directly using the node interpreter
You can directly invoke node to run the program as follows: 
```
  node entry-point.mjs
```

This works fine  for this project, but for larger project were there
are complexities,  it may be better to use the other option described
below.

### Option 2: Run using npm 
For this option to work you should have added the program to the
scripts section of the package.json file. Once you have done so,
run the program using npm as follows:
```
  npm run entry-point
```
The argument to the run command is the name you gave the script when
you added an entry to scripts section of package.json. In this case we
called it 'entry-point'. Had you named the program 'myapp' in the
script section of package.json, then you would invoke the program
as follows:
```
  npm run myapp
```

## npm start and npm test
If you have entry named "start" in the scripts dictionary, you can
invoke it as follows. You don't need to use run.
```
npm start
```

Similarly, "test" is a special script name. You can invoke it as
follows:
```
npm test
```
Note that by default, test is implemented as a bash command that
prints a message saying that no tests have been specified.

See NN-unittests for more information on running tests.

## Setting up a Checked out Project
If it's been a while since you used the project, or you have upgraded
to a new node version, delete any folder named node-modules in the
project directory before following the instructions below.

To set up a checked out project which already has a package.json
Simply run 
```
  npm install
```
This will install all the dependencies  specified in package-lock.json
if it exists. If it doesn't exist, it will create a package-lock.json
and install the packages and dependencies required by the root level
packages specified in package.json.

You should check in the created package-lock.json.
This way anyone else who checks out your project (or you yourself
on in another location or, on another machine), will get the same
set of package dependencies.

## Updating dependencies on a Project
Run the following command to update all the dependencies
of a project. Note that this might break existing code
```
  npm update --save
```
If you want to update a single package to the latest
minor version, then specify the name of the package
as follows:
```
  npm update --save package-name
```

For example to update the express package:
```
  npm update --save express
```

This will not change the major version though, 
even if a new major version has been released.

To do that. First uninstall the package
and then install it again:

```
  npm uninstall express
  npm install express
```

For more details about updating packages, check out
the article on 
[Stack Overflow](https://stackoverflow.com/questions/43127863/node-update-a-specific-package).


## Creating an IntelliJ IDEA project
Start IntelliJ IDEA and open the project. i.e. the directory containing
the project. Do this only after you've set up the project using npm.
Note that this only needs to be done once.

### Turn on Coding Assistance for Node.js
Then go to IntelliJIDE (or File) -> Settings -> Languages & Frameworks
-> Node.js. Then check the box that says 'Coding assistance for
Node.js'.

### Setup Run Configurations
Then go to Run -> Edit Configurations. Click on the + sign and
select 'Node.js'. Then set the Javascript file to the
entry-point.mjs

### Check in all committable project artifacts
Check in the '.idea' directory. This is the IntelliJ
IDEA project. Some things like run configurations won't
be checked in, but everything else will.

---

# Appendix A: How Package.json and Package-lock.json Work

<div style="border: 1px solid #ff9933; padding: 10px; margin: 10px 0; color: black; background-color: #fcd0b1; border-radius: 5px;">
  Note that this is an AI generated explanation. Treat with caution.
</div>


In an NPM (Node Package Manager) project, two important files manage
dependencies: **`package.json`** and **`package-lock.json`**. Each
serves a distinct but related purpose.


## 1. `package.json` — **Project Manifest**

* **Purpose**: Defines the project’s metadata and its direct dependencies.

* **Contains**:

  * Project name, version, description
  * Script commands (like `npm start`, `npm test`)
    * **Dependency declarations** (but not their exact installed versions):

      ```
      "dependencies": {
        "express": "^4.18.0"
      }
      ```
      Here, `^4.18.0` means "any minor/patch version compatible with
      4.x.x".

* **Key role**:
  When someone runs `npm install`, NPM looks here to know what
* packages (and versions ranges) are needed.


## 2. `package-lock.json` — **Exact Dependency Snapshot**

* **Purpose**: Locks down the exact versions of all dependencies (direct and indirect) that were actually installed.

* **Contains**:

  * Precise versions and resolved URLs of all modules.
  * Dependency tree (how libraries depend on each other).

* Example snippet:

  ```
  "node_modules/express": {
    "version": "4.18.2",
    "resolved": "https://registry.npmjs.org/express/-/express-4.18.2.tgz"
  }
  ```

* **Key role**:
  Ensures reproducible installs — the exact same versions get installed on any machine (for you, your team, CI/CD pipelines, etc.).

## Summary of Differences:

| Aspect                          | `package.json`      | `package-lock.json`            |
|---------------------------------|---------------------|--------------------------------|
| **Required in project?**        | Yes                 | Automatically generated by NPM |
| **Tracks exact versions?**      | No (version ranges) | Yes (exact versions)           |
| **Controls reproducibility?**   | No                  | Yes                            |
| **Should be committed to Git?** | Yes                 | Yes                            |
| **Edited by hand?**             | Yes                 | Rarely (usually auto-managed)  |

### Simple analogy:

| **package.json**                                  | **package-lock.json**                                            |
|---------------------------------------------------|------------------------------------------------------------------|
| **Recipe**: "Get chocolate between 70–85% cocoa." | **Shopping receipt**: "Bought 72% cocoa Lindt bar from Store X." |

