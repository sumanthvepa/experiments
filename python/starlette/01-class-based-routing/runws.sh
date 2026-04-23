#!/usr/bin/env bash
# Scrpt to run the cbrws webservice in a dev environment

CBRWS_DEBUG=true uvicorn --log-config config/log-config.dev.json cbrws.application:app --host=0.0.0.0 --port=5101 --reload
