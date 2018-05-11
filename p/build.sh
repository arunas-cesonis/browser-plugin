#!/bin/sh
set -eu
bower install
pulp browserify $@ --to dist/out.js
