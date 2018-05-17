#!/bin/sh
set -eu
cd $(dirname $0)
npm i
node app.js
