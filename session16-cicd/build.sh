#!/usr/bin/env bash
set -euo pipefail
mkdir -p build
cp app/calculator.py build/
printf 'Application: Session 16 Calculator
Build Status: SUCCESS
' > build/build-info.txt
python -m compileall -q app
echo 'Build completed successfully.'
