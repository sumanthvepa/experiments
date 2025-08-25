This is a very basic jupyter lab setup.

To install Jupyter do the following:

1. Create a python project using the steps outlined in
python/01-remote-idea-python
2. Create package.txt with the packages needed for jupyter.
3. Install the packages using packages2.sh
4. Create src/npnjupyter/
5. Create src/npnjupyter/__init__.py
6. Set the environment variable JUPYTER_CONFIG_DIR=/path/to/src/npnjupy
7. Create a Jupyter configuration using the following command:
   JUPYTER_CONFIG_DIR=./src/nfnjupyter/config.py lab --generate-config
8. Edit the following entries in the file:
   c.ServerApp.ip = '0.0.0.0'
   c.ServerApp.open_browser = False # Don't attempt to open a browser
   c.ServerApp.port = 5150

9. Start the server with the server.sh script.
10. Open the firewall at port 5150 (or whatever port you selected)
    sudo firewall-cmd --add-port=5150/tcp 
    You can make it peramanent if you want. But I choose not to.
