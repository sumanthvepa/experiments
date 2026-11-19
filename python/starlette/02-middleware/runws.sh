#!/usr/bin/env bash
# Script to run the middleware web service in a dev environment

uvicorn mws.application:app --host=0.0.0.0 --port=5102 --reload
