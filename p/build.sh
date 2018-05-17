#!/bin/sh
set -eu
cd $(dirname $0)
bower install
npm i
pulp browserify $@ --to dist/out.js
