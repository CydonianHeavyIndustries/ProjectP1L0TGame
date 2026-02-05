@echo off
setlocal

cd /d "%~dp0"

set ELECTRON_RUN_AS_NODE=

if not exist node_modules (
  echo Installing dependencies...
  npm install
)

node start.js
