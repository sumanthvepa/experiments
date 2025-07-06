This project demonstrates the process of setting up a
Python project running on a remote Linux host that can
be used with IntelliJ IDEA.

The process of setting up the project is finicky because
IntelliJ IDEA remote SSH projects feature, while it is
really useful, is brittle and has subtle bugs that will
essentially be a showstopper when encountered.

## Phase 1: Create a clean environment

First, make sure you have IntelliJ IDEA setup properly on the host

This is not always required. If you've set up the IDE properly
then you probably don't have to do this step. But if you encounter
problems, it's best to clean up.

### Phase 1. Step 1: Clean up ~/.local

If you've used pip to install packages without a venv or running as root.
The chances are that you've polluted your path with various python
utilities that have been installed into ~/.local.

Also, IntelliJ IDEA stores configuration and state in ~/.local

The problem is that ~/.local is it is used by many tools, particularly
commercial ones like Visual Studio Code and IntelliJ IDEA. So cleaning
up this directory runs the risk that you will blow away state of
some other software. The good news for me is that the only tools
that use this in my context are python, node, VS Code, and IntelliJ IDEA.
All of which I was okay with blowing away.

```bash
    cd ~/.local
    rm -fr *
```    

### Phase 1. Step 2: Clean up ~/.cache/
It is safer to simply remove all the stuff in this directory. Once
again its the usual suspects (python, node, VS Code and IntelliJ IDEA
in my case) that use this directory.

cd ~/.cache
rm -fr *

## Phase 2: Create the non-IDE portion of the project

In this step we create a standard Python project using venv.
There is nothing IntelliJ IDEA specific in this phase

### Phase 2 Step 1: Create the project directory

Nothing complicated here. Just create the directory where you want the
project to live on your host machine. You may want that to be part of
a checked-out git repository.

0For this project. The git repo already exists -- it's part of the
'experiments' repository.

All I needed to do was create the directory in the python folder.

mkdir 01-remote-idea-python

### Phase 2: Step 2: Create the python venv

I use python venv. I've been using this for a long time, and I'm
happy with it.

python3.12 -m venv venv

### Phase 2: Step 3: Install pylint and mypy into the venv

I use a script call packages.sh that reliably installs the packages
I need. It needs to be run after sourcing the venv environment

source venv/bin/activate
./packages.sh

### Phase 2: Step 4: Copy pylintrc and mypy.ini into the project root

When you copy pylintrc, make sure you change the init-hook inline script
to use the path to the root of your project. Use mypy.ini and pylintrc
in this project as templates for your own copies.

### Phase 2: Step 4: Create the src and tests directories

This structure is needed to package python projects for deployment
with pip. Even if you don't intend to package the project pip, it's
a good idea to go with this structure

mkdir src tests

## Phase 3: Create the IntelliJ IDEA project

### Phase 3: Step 1: Create the IntelliJ IDEA remote SSH project

Open your IntelliJ IDEA IDE on your client and start a remote SSH
project. Make sure you are NOT selecting an EAP (Early Access Program)
IDE backend. It usually doesn't work. Only try it if you have problem
with the stable backend and, you want to see if the EAP fixes it.

Select the path to the project's root directory and then connect and open
the remote IDE.

Be patient while the IDE potentially downloads the backend and starts
it.

### Phase 3: Step 2: Check that all required plugins have been installed

In particular ensure that Python, Python Community Edition, Pylint
and MyPy plugins have been installed. I also install GitHub Copilot

### Phase 3: Step 3: Configure the python virtual environment

Got to File -> Project Structure -> Project. Choose Existing environment
and select the python3.12 (or your preferred latest version) interpreter
in the venv/bin directory of your project's virtual environment.

Restart your IDE backend at this point. Exit and stop the backend.
The open the project again from the client.

### Phase 3: Step 4: Configure pylint

Go to IntelliJ IDEA -> Settings -> Tools -> Pylint
Make sure that the pylint executable corresponds to the one in the
virtual environment you are using.
Specify the path to the pylintrc file in the field for configuration.

### Phase 3: Step 5: Configure mypy

Go to IntelliJ IDEA -> Settings -> Tools -> MyPy
Make sure that the mypy executable corresponds to the one in the
virtual environment you are using.
Specify the path to the mypy.ini file in the field for configuration.

Restart your IDE after this step to allow the plugins to get the
new configuration.

### Phase 3: Step 6: Mark src as sources root

Right-click on the src directory in the navigation panel on the left
and choose Mark Directory as -> sources root.

### Phas 3: Step 7: Mark tests as test root

Right-click on the tests directory in the navigation panel on the left
and choose Mark Directory as -> test root.

### Phase 3: Step 8: Mark venv as Excluded

Right click on venv and choos mark directory as excluded. This prevents
IntelliJ IDEA from indexing the directory. It improves performance
and saves memory and disk space.

Restart the IDE at this point

## Phase 4: Add Sources and test files

### Phase 4: Step 1: Create the source files

Create the source files in the src directory. Check that imports both
within the module and outside it work properly in the IDE

### Phase 4: Step 2: Create test files in the tests directory

I create a module named test with submodule with the same structure
as the modules in source. See the directory structure of tests in
this project to see how it is done.

At this point you have a fully functioning IntelliJ IDEA remote project
