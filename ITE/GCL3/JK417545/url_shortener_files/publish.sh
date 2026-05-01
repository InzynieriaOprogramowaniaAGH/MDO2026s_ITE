#!/bin/bash
BUILD_IMAGE=$1

echo "------------------------------------------"
echo "Starting Publish to NPM.js process..."

docker run --rm -v $(pwd):/out $BUILD_IMAGE cp -r /app/package.json /app/dist /out/

docker run --rm -v $(pwd):/out -w /out node:20-alpine sh -c "
  echo '//registry.npmjs.org/:_authToken=${NPM_TOKEN}' > .npmrc
  npm pack
  npm publish --access public
"

echo "------------------------------------------"