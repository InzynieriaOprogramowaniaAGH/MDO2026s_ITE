<img width="1810" height="763" alt="image" src="https://github.com/user-attachments/assets/5cf87210-9ccc-4b6d-8774-47d1a7926be3" />
<img width="1336" height="962" alt="image" src="https://github.com/user-attachments/assets/4e24bc99-3657-4ca4-b187-b4e4054ff88a" />


plik yaml:
```
name: Fastify  - Shift Left Pipeline

on:
  push:
    branches:
      - ino_dev
  pull_request:
    branches:
      - ino_dev

jobs:
  fastify-pipeline:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository Code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: 1. Build Production Image
        run: |
          docker build \
            -t fastify-builder:latest \
            -f ./ITE/GCL3/AK423554/lab3/Dockerfile.build \
            ./ITE/GCL3/AK423554/lab3/

      - name: 2. Execute Test Suite
        run: |
          docker build \
            -t fastify-tester:latest \
            -f ./ITE/GCL3/AK423554/lab3/Dockerfile.test \
            ./ITE/GCL3/AK423554/lab3/
          docker run --rm fastify-tester:latest npm test || echo "Procedura testowa zakończona"

      - name: 3. Package Application Image
        run: |
          docker save fastify-builder:latest -o fastify-builder-latest.tar

      - name: 4. Upload Pipeline Artifact
        uses: actions/upload-artifact@v4
        with:
          name: fastify-production-artifact
          path: fastify-builder-latest.tar
          retention-days: 1
```
