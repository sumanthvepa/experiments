# Creating and Managing a NodeJS/NPM Project
This project and file describes how to setup a simple nodejs
project.

## Install NodeJS and NPM
### Installation Instructions for MacOS
The first step is to ensure that you've installed node and
npm on your system.

On MacOS using MacPorts. Note that nn s
```
  sudo port install nodejsNN 
```

Replace NN with the actual node version you want to install
For example:

```
  sudo port install nodejs20
```

I tend to stick with LTS releases of node rather than live
on the bleeding edge.
  
Then install npm the node package manager
  sudo port install npmNN
Replace npm with the version of npm that you need.
For example:

```
  sudo port install npm10
```

### AlmaLinux setup instructions
Check to see if nodejs 20 is available
```
  dnf -y module list nodejs
```
Make sure other version of nodejs are disabled
```
  dnf -y module reset nodejs
  dnf -y module enable nodejs:20
```

Install nodejs:20
```
  dnf -y module install nodejs:20/common
```

### Altertnative instructions for containers

You can install node from nodesource RPMs
or 
NodeJS Binaries. See docker/basics/10-docker-build-node.sh
and 11-docker-build-node-optimized for instructions

## First Time Setup
The following instructions are for first time setup. i.e. when
you are creating the project. If you've checked out an existing
project see  section on setting up an existing project.

## Initialize npm for the project
You can find a good tutorial for this at
[Node Source](https://nodesource.com/blog/an-absolute-beginners-guide-to-using-npm/).

```
  npm init
```

## Intall Project Dependencies
Then install project dependencies. For this project we are going to
install commander and express.

```
  npm install commander
  npm install express
```

If a package is only needed during development (for example:
a test framework,) Then install it as follows:

```
  npm install --save-dev mocha
```

This will create a package.json and package-lock.json

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
I typically do both, although that is unnecesary.

I prefer Javascript modules, as they enforce certain
things that make life easier for large scale development.

## Preparing the package for running
Then proceed to create the package entry point file
with the code you want to run.

Then add a program command to the scripts to run the program
using npm.

For example, you can create a key named 'entry-point' whcih
invokes the entry-point.mjs script using node:

```
  "scripts": {
    "entry-point": "node entry-point.mjs"
  }
```
Note you may have to add a comma, if there are
other scripts.

For web servers, it is traditional to call the primary
script 'start'. This is a special script name that you
can invoke directly without using 'run'. See below
for a more detailed explanation.

## Running the program
You can directly invoke node to run the program:

```
  node entry-point.mjs
```

You can also run the progam using npm (provided
you added the "entry-pont" to scripts in package.json)
as follows:

```
  npm run entry-point
```

If you have entry named "start" in the scripts
dictionary, you can invoke it as follows. You
don't need to use run.

npm start

Similarly "test" is a special script name.
You can invoke it as follows:

npm test.

Note that by default, test is implemented
as a bash command that prints a message
saying that no tests have been specified.

See NN-unittests for more information on
running tests.

## Setting up a Checked out Project

To setup a checked out project which 
already has a package.json. Simply
run 
```
  npm install
```
This will install all the dependencies
specified in package.json.

This may result in package-lock.json
being updated. That's okay.

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
[on Stack Overflow](https://stackoverflow.com/questions/43127863/node-update-a-specific-package).



## Creating an IntelliJ IDEA project

Start IntelliJ IDEA and open the project. i.e the directory containing
the project. Do this only after
you've set up the project using npm. Note that
this only needs to be done once.

### Turn on Coding Assistance for Node.js
Then go to IntelliJIDE (or File) -> Settings -> Languages & Frameworks
-> Node.js. Then check the box that says 'Coding assistance for
Node.js'.

### Setup Run Configurations
Then go to Run -> Edit Configurations. Click on the + sign and
select 'Node.js'. Then set the Javascript file to the
entry-point.mjs

### Check in all committable project artifacts
Check in the.idea directory. This is the IntelliJ
IDEA project. Some things like run configurations won't
be checked in, but everything else will.
