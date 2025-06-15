# Creating and Managing a Node.js/NPM Project
This project and file describes how to set up a simple Node.js project.

<!-- toc -->

  * [Install NodeJS and NPM](#install-nodejs-and-npm)
    + [Installation Instructions for macOS](#installation-instructions-for-macos)
    + [AlmaLinux setup instructions](#almalinux-setup-instructions)
    + [Alternative instructions for containers](#alternative-instructions-for-containers)
  * [First Time Setup](#first-time-setup)
  * [Initialize npm for the project](#initialize-npm-for-the-project)
  * [Install Project Dependencies](#install-project-dependencies)
  * [Add support for ES6 imports](#add-support-for-es6-imports)
  * [Preparing the package for running](#preparing-the-package-for-running)
  * [Running the program](#running-the-program)
    + [Run directly using the node interpreter](#run-directly-using-the-node-interpreter)
    + [Run With npm](#run-with-npm)
  * [npm start and npm test](#npm-start-and-npm-test)
  * [Setting up a Freshly Checked Out Project](#setting-up-a-freshly-checked-out-project)
  * [Updating node_modules when git pull brings in changes to package-lock.json](#updating-node_modules-when-git-pull-brings-in-changes-to-package-lockjson)
  * [Updating a Checked out Project](#updating-a-checked-out-project)
    + [Updating package-lock.json](#updating-package-lockjson)
    + [Updating major versions in package.json](#updating-major-versions-in-packagejson)
      - [Manually updating package.json](#manually-updating-packagejson)
      - [Automatically updating package.json](#automatically-updating-packagejson)
  * [Creating an IntelliJ IDEA project](#creating-an-intellij-idea-project)
    + [Turn on Coding Assistance for Node.js](#turn-on-coding-assistance-for-nodejs)
    + [Setup Run Configurations](#setup-run-configurations)
    + [Check in all committable project artifacts](#check-in-all-committable-project-artifacts)
- [Appendix A: How Package.json and Package-lock.json Work](#appendix-a-how-packagejson-and-package-lockjson-work)
  * [1. `package.json` — **Project Manifest**](#1-packagejson--project-manifest)
  * [2. `package-lock.json` — **Exact Dependency Snapshot**](#2-package-lockjson--exact-dependency-snapshot)
  * [Summary of Differences:](#summary-of-differences)
    + [Simple analogy:](#simple-analogy)
- [Appendix B: Colophon](#appendix-b-colophon)

<!-- tocstop -->

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
  npm install --save commander
  npm install --save express
```

If a package is only needed during development (for example:
a test framework, a linter, or a transpiler like typescript), then
install it as follows:
```
  npm install --save-dev mocha  # Replace mocha with the package you want to install
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

### Run directly using the node interpreter
You can directly invoke node to run the program as follows: 
```
  node entry-point.mjs
```
This works fine  for this project, but for larger project were there
are complexities,  it may be better to use the other option described
below.

### Run With npm
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

## Setting up a Freshly Checked Out Project
When you check out an existing project that already has a package.json
file and a package-lock.json file, then you should run:
```
  npm clean-install
```
This will install all the dependencies specified in package-lock.json.
No changes will be made to package-lock.json. The exact versions
of the packages specified in package-lock.json will be installed.

This is desirable, if you want to ensure that you are building against
the same set of packages that were used when the package-lock.json
was checked in.

## Updating node_modules when git pull brings in changes to package-lock.json
If you run `git pull` and it brings in changes to package-lock.json,
then you should run the following command:
```
  npm clean-install
```
This will update the node_modules directory to match the new package-lock.json.

If your project has been checked out for a while, you may want to clean
up old dependencies that are no longer needed. You can do this
by running the following command:
```
  npm prune
```
This will remove any packages that are no longer listed in
package-lock.json or package.json. This is useful if you have removed
a package from package.json, or you have updated package.json to a new
version of a package.

Once in a while, it might make sense to complete remove the node_modules
directory and reinstall all the packages from scratch. This can help
resolve issues with corrupted packages or mismatched versions. To do this,
you can run the following commands:
```
    rm -fr node_modules
    npm clean-install
```

## Updating a Checked out Project
### Updating package-lock.json
The direct dependencies of the project are specified in the package.json
file. npm treats the versions specified in package.json as ranges. 

When you install a package for the first time using
npm install <package-name>, npm will install the latest version
of the package, and update the package-lock.json file to the exact
version of the package and its dependencies that were installed.

If you want to update to the latest version of all dependencies, both
the direct dependencies and the indirect dependencies, that ARE COMPATIBLE
WITH VERSION RANGES SPECIFIED IN package.json, then run the following command:
```
  npm update --save
```
This will update the package-lock.json file to reflect the latest
compatible versions of the packages and their dependencies.
You should check in the updated package-lock.json file.

If you want to update a specific package to the latest version
that is compatible with the version range specified in package.json,
then specify the package name as follows:
```
  npm update --save package-name
```
For more details about updating packages, check out
the article on 
[Stack Overflow](https://stackoverflow.com/questions/43127863/node-update-a-specific-package).

### Updating major versions in package.json

#### Manually updating package.json
If you want to update the version of a package to a major version
that is not compatible with the version range specified in package.json,
you can manually edit the package.json file and change the version
range for the package to the new version. 

For example, if you want to specify that you want any minor or patch
version of lodash in the 4.x.x series, you would change the
dependencies section of package.json to:
```
  "dependencies": {
    "lodash": "^4.0.0"
  }
```
The '^'(caret) symbol indicates that you want any minor or patch
version of lodash that is compatible with 4.x.x. (It is assumed that
all minor and patch versions in the 4.x.x. series are backwards
compatible with each other. It is the responsibility of the library
maintainers to ensure that this is the case.)

IF you want to only want patch version updates, you can use the
'~' (tilde) symbol instead:
```
  "dependencies": {
    "lodash": "~4.0.0"
  }
```
This indicates that you want any patch version of lodash in the 4.0.x
series, but not any minor version updates. This is useful if you
want to ensure that you are not introducing any new features that
may break your code, but you still want to get bug fixes.

Finally, if you want to update to a specific version, you can
specify the exact version number:
```
  "dependencies": {
    "lodash": "4.17.12"
  }
```

Do this for all the packages you want to update in package.json.

After you have manually updated package.json, you should run the
following command to update the package-lock.json file:
```
  npm install
```


#### Automatically updating package.json
Install the npm-check-updates package locally. The normal advice is 
to install it globally (i.e. available to all projects on the machine),
but I prefer to keep it local to the project. This avoids inadvertently
creating a dependence on a global package that may not be available
in a different environment (e.g. a container or a different machine).

To install npm-check-updates locally, run the following command:
```
  npm install --save-dev npm-check-updates
```
Now you can use the ncu command to check for updates to the packages.
Since this is a local installation, you need to run it using npx:
```
  npx ncu
```
This will show you a list of packages that have newer versions
available.

Now you can do the actual update. To update all packages to their latest
versions, run the following command:
```
  npx ncu -u  # This updates package.json with the latest versions
  npm install # This installs the latest versions node modules and updates package-lock.json
```

You can also check and update specific packages. For example, to
update the lodash package to its latest version, run the following command:
```
  npx ncu -u lodash # Update package.json to the latest version of lodash
  npm install # Install the latest version of lodash and update package-lock.json
```

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
<!--suppress SpellCheckingInspection, SpellCheckingInspection, SpellCheckingInspection -->
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

---
# Appendix B: Colophon
This document was created by manually editing a markdown file.
The table of contents was created using the markdown-toc npm package.
This can be installed locally using the following command:
```
  npm install --save-dev markdown-toc
```

Then you can run the following command to generate the table of contents:
```
  npx markdown-toc -i README.md
```
The same command can be used to update the table of contents as well.

To locate the ToC in a specific place in the document, you can use the
phrase 'toc' in a comment, and the phrase 'tocstop' in a following
comment. When markdown-toc runs, it will place the ToC between these
two comments.