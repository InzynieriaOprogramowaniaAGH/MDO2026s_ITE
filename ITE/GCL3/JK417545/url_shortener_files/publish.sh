#!/bin/bash

BUILD_IMAGE=$1

echo "------------------------------------------"
echo "Starting Publish process..."

docker run --rm -v $(pwd):/out $BUILD_IMAGE cp -r /app/package.json /app/dist /out/
docker run --rm -v $(pwd):/out -w /out node:20-alpine npm pack

echo "Package created successfully."
echo "------------------------------------------"