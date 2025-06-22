# 00-boilerplate: A Basic Static Website Boilerplate

## Summary
This project demonstrates a purely static website that has all
the boilerplate needed for a basic static website.

It uses HTML, CSS, and JavaScript from the html5boilerplate project
as the foundation.

## Creation Process
This section describes the steps taken to create this project.

### Set Up the NPM Project
1. Create a new directory for the project.
2. Run the following command to initialize a new NPM project:
   ```bash
   npm init
   ```
3. Remove the "main" field from the `package.json` file, as this 
project does not have a main Javascript entry point:
4. Add the key "private": true to the `package.json` file to prevent  
accidental publishing:
   ```json
   {
     "private": true
   }
   ``` 
5. Install html5-boilerplate as a development dependency:
   ```bash
   npm install html5-boilerplate --save-dev
   ```
6. Create a symbolic link to the script boilerplate.sh in the
   `experiments.git:utilities/bin/` directory:
   ```bash
   ln -s ../../ boilerplate.sh # You may need to adjust the path based
                               # on your directory structure
   ```
7. Run the script boilerplate.sh (located in 
experiments.git/utilities/bin/boilerplate.sh) to copy the boilerplate
files from the html5-boilerplate package to the project directory:
   ```bash
   boilerplate.sh
   ```
   This script is both idempotent and fail-save. You can run it
   multiple times without issues, and it will not overwrite existing
   files.
8. Install a local web server for testing purposes:
   ```bash
   npm install http-server --save-dev
   ```
9. Start the local web server:
   ```bash
   npx http-server --port 5000 # Change the port as needed
   ```
10. You may need to open the port on your hosts firewall to allow 
access. Only do this if you are running your browser on a different
machine than the host (or VM) on which this server is running.
For Almalinux and Fedora, you can use the following command:
    ```bash
    sudo firewall-cmd --add-port=5000/tcp
    ```
Now you're done. You can open your web browser and navigate to
[http://localhost:5000](http://localhost:5000) (or if you are running 
in a VM, use the name or IP address of the VM) to see your static
website in action.

## Setting Up the IntelliJ IDEA Project
For the most part setting up an IntelliJ IDEA project should be
identical to the process outlined in /javascript/basics/00-setup.

Just remember to mark the directory 00-boilerplate as sources root.
Other than that you're good to go.

