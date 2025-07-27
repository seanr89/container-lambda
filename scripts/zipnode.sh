#!/bin/bash
set -euo pipefail

cd ../nodelambda

zip -r deployment_package.zip index.js
## or zip -r deployment_package.zip . -x "*.git*" "package-lock.json" "node_modules/.bin/*"
