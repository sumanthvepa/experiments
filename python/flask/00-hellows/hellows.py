#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  hellows.py: A simple flask application that sends the string 'hello'
"""
# -------------------------------------------------------------------
# hellows.py: A simple flask application that sends the string 'hello'
#
# Copyright (C) 2024 Sumanth Vepa.
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License a
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see
# <https://www.gnu.org/licenses/>.
# -------------------------------------------------------------------

# Step 0: Set up the python environment needed to run a Flask
# application.
# Step 0a: Create a python virtual environment
#   mkdir the project directory.
# Step 0b: Create the virtual environment
#   In the project directory, create the virtual run
#   python3.12 -m venv 'venv'
# Step 0c: Activate the virtual environment:
#   source venv/bin/activate
# Step 0c: Install Flask and common python dependencies
#   Install the basic python dependencies and flask into the virtual env
#   python3 -m pip install --upgrade pip
#   python3 -m pip install pylint
#   python3 -m pip install mypy
# Step 0d: Copy the standard pylintrc file from another project
#   cp $WORKSPACE/experiments/python/basics/pylintrc .

# Step 1: Setup IDE (IntellJ IDEA or Visual Studio Code)
# Step 1A: Setup IntelliJ IDEA
# Step 1Aa: If you want to run the flask web service locally on your
#           own machine.
#          TODO: Write instructions for this
# Step 1Ab: If you want to run the flask web service in a remote linux VM.
#   Step 1Ab-1:   In the IntelliJ IDEA
#                 <a href="python-flask-remote-project-screen01.png">
#                 initial screen ('Welcome to IntelliJ IDEA')</a>
#   Step 1Ab-2:   Select SSH under Remote Development from the menu on the left.
#                 <a href="python-flask-remote-project-screen02.png">
#   Step 1Ab-3:   In the button-cum-dropdown at the top right name 'New Project'
#                 Select the dropdown and choose 'Connect to Host'
#                 <a href="python-flask-remote-project-screen03.png">
#   Step 1Ab-4:   Either choose an existing connection or 'New connection' for the
#                 connection entry, if you want to create a new connection.
#                 <a href="python-flask-remote-project-screen03.png">
#   Step 1Ab-4a:  For a new connection. I recommend choosing the gear icon
#                 to create new connection.This will allow you to use the
#                 ssh-agent on your machine to connect.
#   Step 1Ab-4b:  For an existing connection, just select the connection you
#                 want. Finally select Check connection and continue at
#                 the bottom left.
#   Step 1b-5:    You are taken back to the welcome screen, but now your
#                 host is available as one of the options in Recent
#                 SSH Projects Click + sign next to that host to create
#                 a new project on the host
#                 <a href="python-flask-remote-project-screen05.png">
#   Step 1b-6:    Choose the IDE and project. DO NOT GO with the
#                 default IDE choice, as it will choose an experimental
#                 EAP release by default. Instead choose the IDE
#                 version that matches the IDE version on your machine.
#                 <a href="python-flask-remote-project-screen65.png">
#   Step 1Ab-7:   Then select the project directory on the remote
#                 host. 
#                 <a href="python-flask-remote-project-screen07.png">
#                 Then click download IDE and connect. This will
#                 start the process of downloading the IDE backend onto
#                 the remote host. Essentially an entire copy of JetBrains
#                 IntelliJ IDEA will be installed in ~/.cache/JetBrains on
#                 the remote machine. It takes up about 2GiB of disk space
#                 and will require at least 5GiBs of RAM on the VM to
#                 run. DO NOT develop this way on cloud VMs. Do it with
#                 VMs that are running on your own infrastructure.
#                 <a href="python-flask-remote-project-screen08.png">
#   Step 1Ab-8:   Configure the Project on the Remote Host
#                 After the download is complete the standard project
#                 window is opened
#                 <a href="python-flask-remote-project-screen09.png">
#   Step 1Ab-8-1:    First configure plugins on the host. Open
#                    IntelliJ IDEA -> Settings from the main menu.
#                    Make sure that the following plugins are
#                    installed on the host:
#                    Python (this should already be present, but just
#                            in case...)
#                    Pylint (All my projects use pylint and I want to
#                            see warnings in the IDE) Choose the one
#                            by Roberto Leinardi
#                    MyPy (Roberto Leinardi): The 'official' mypy
#                    stuff does not work well.
# #                 <a href="python-flask-remote-project-screen10.png">
#   Step 1Ab-8-2:   Configure the python interpreter. File -> Project
#                   Structure -> SDKs (on the left menu). Click + on
#                   above the list of SDKs Then choose existing
#                   environment Choose the python3.12
#                   interpreter in venv/bin/python3.12 in the projects venv
#                   directory. Click Ok and add the interpreter.
#                   Then re-open File -> Project Structure.
#                   Select Project Settings -> Project. Select the python
#                   interpreter you selected. Click Apply at the bottom right
#                   and then ok.
#                   <a href="python-flask-remote-project-screen05.png">
#  Step 1Ab-9:      Check that interpreter is recognized. Open
#                   hellows.py and check that there is no warning for
#                   the file.
#  Step 1Ab-10:     Configure a runtime. You may see a runtime configuration
#                   already present (top right corner just befor the play button)
#                   Click the drop down select edit configurations to bring up
#                   the run-debug configurations window. Delete the default
#                   configuration if present. Click plus to add a new configuration.
#                   Choose flask server. Change the name to hellows
#                   Select the interpreter in the venv (this should already be
#                   be selected. The select the type of entity that flask
#                   should run. For hellows, it script and the path to the script
#                   should be given. Click on the modify options link, click
#                   additional options. This will bring up a new text box into
#                   which you should specify the the host addresses and port
#                   on which to run. I use --host=0.0.0.0 --port=5000 to allow
#                   me to access the flask app from outside the VM. Remember
#                   on Linux to run firewall-cmd --add-port=5000/tcp from
#                   the command line to ensure that the port is open.
#                   Alternatively you can set the flask port and host with
#                   FLASK_RUN_HOST=0.0.0.0 and FLASK_RUN_PORT=0.0.0.0 by
#                   setting them in the Environment variables section.
#                   <a href="python-flask-remote-project-screen16.png">
#                   This is described here:
#                   https://stackoverflow.com/questions/41940663/how-can-i-change-the-host-and-port-that-the-flask-command-uses # pylint: disable=line-too-long
#                   Click Apply and then click Ok.
#                   Check that everything works by clicking the 'Play/Run'
#                   button on the IDE and then checking if the app is accessible
#                   from the browser.

# Step 1B: Setup Visual Studio Code
# Step 1Ba: If you want to run the flask web service locally on your own machine.
#          TODO: Write instructions for this
# Step 1Bb: Setup Remote development over SSH
# Step 18b-1:  Install the Remote Development Extension from Microsoft
# Step 18b-2:  Open the command palette (Ctrl+Shift+P) and type 'Remote-SSH'
# Step 18b-3:  Select 'Remote-SSH: Connect to Host' from the dropdown
# Step 18b-4:  Select 'Add New SSH Host' from the dropdown
# Step 18b-5:  SEtup the new connection
#              Enter the SSH connection string in the format
#              user@hostname:port
#              If you are using a non-standard port, you can specify
#              the port number in the connection string.
#              If you are using a non-standard username, you can specify
#              the username in the connevscode-ction string.
#              If you are using a non-standard private key, you can specify
#              the private key in the connection string.
#              Now select the connection to open a connection to the new
#              host. This will open a new window with the remote host.
#              You can see that by looking at the bottom left corner of the
#              window. You should see the name of the host you are connected
#              to. You can also see the name of the host in the title bar
#              of the window.
#              <a href="vscode-python-flask-remote-project-screen01.png">
# Step 18b-6:  Install the extensions you need for the project.
#              For a python flask project, you will need the following
#              extensions:
#              Python (Microsoft)
#              Pylint (Microsoft)
#              MyPy (Microsoft)
#              Github Copilot (Microsoft)
#              <a href="vscode-python-flask-remote-project-screen02.png">
# Step 18b-7:  Open the project directory in the remote host.
# Step 18b-8:  Configure the python interpreter
#              Open the hellowws.py file in the project directory.
#              You can do this by clicking on the python version in the
#              bottom left corner of the window. This will bring up a
#              dropdown list of python interpreters. It should automatically
#              detect the python interpreter in the venv directory of the
#              project. If not, you can select the python interpreter
#              in the venv directory of the project.
# Step 18b-9:  Configure flask runtime
#              Open the hellows.py file in the project directory.
#              Select the debug icon on the left side of the window.
#              This will open the debug view.
#              Choose the 'create a launch.json file' option.
#              This will take you through a series of steps to select
#              the type of runtime you want to create. Choose flask.
#              Edit the launch.json file to add the host and port
#              options to the flask command. I use --host=0.0.0.0 and
#              --port=5000 to allow me to access the flask app from
#              outside the VM. Remember on Linux to run
#              firewall-cmd --add-port=5000/tcp.
#              Alternatively you can set the flask port and host with
#              FLASK_RUN_HOST=0.0.0.0 and FLASK_RUN_PORT=5000
#              by setting them in the Environment variables section.
#              Note that Visual Studio Code has a port forwarding
#              feature that allows you to access the flask app from
#              from your local machine. You can manage port forwarding
#              clicking on the ports tab in bottom panel.
#              <a href="vscode-python-flask-remote-project-screen03.png">
#              <a href="vscode-python-flask-remote-project-screen04.png">
#              <a href="vscode-python-flask-remote-project-screen05.png">
#              <a href="vscode-python-flask-remote-project-screen06.png">
# Step 18b-10: Check that everything works by clicking the 'Play/Run'
#              button on the IDE and then checking if the app is
#              accessible from the browser.
# See the following links for how to do remote development with Visual
# Studio Code: https://code.visualstudio.com/docs/remote/
# See the following link for how to setup for Python and Flask in
# Visual Studio Code: https://code.visualstudio.com/docs/python/tutorial-flask
from flask import Flask

app = Flask(__name__)


@app.route('/')
def hello() -> str:
  """ Return the string 'hello'"""
  return "hello"
