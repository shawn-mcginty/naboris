#!/bin/bash
set -e
npm run build-docs
cd docs-src
npm install
npm run load-docs
npm run generate
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../deploy_key -r dist naboris-docs@shawnmcginty.com:~/www