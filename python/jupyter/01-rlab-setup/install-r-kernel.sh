#!/bin/bash
R -e 'install.packages("IRkernel", repos="https://cloud.r-project.org", lib="./rlibs");.libPaths("./rlibs"); IRkernel::installspec(prefix="./venv/share/jupyter/kernels/")'
