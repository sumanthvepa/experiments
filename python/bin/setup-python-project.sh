#!/usr/bin/env bash

TEMPLATE_DIR=$WORKSPACE/experiments/python/01-remote-idea-python

mkdir -p src tests
cp $TEMPLATE_DIR/.gitignore .
cp $TEMPLATE_DIR/pylintrc .
cp $TEMPLATE_DIR/mypy.ini .
cp -R $TEMPLATE_DIR/stubs .
