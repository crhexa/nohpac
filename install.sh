#!/bin/bash

conda create -n nohpac python=3.12
pip install -r python/pip-pkgs.txt -q --no-input --require-virtualenv