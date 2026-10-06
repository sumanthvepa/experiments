#!/usr/bin/env bash
# Script to run the middleware web service in a dev environment

MWS_DEBUG=true uvicorn --log-config mws.application:app --host=0.0.0.0 --port=5102 --reload
