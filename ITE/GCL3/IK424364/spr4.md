Sprawozdanie 4

Github Actions

Najpierw sforkowałem repozytorium (https://github.com/alexey-lapin/realworld-backend-spring), którego do tej pory używałem

Usunąłem dotychczasowy pipeline i przełączyłem na specjalną gałęź

```
rm -rf .github/workflows/*

git checkout -b ino_dev
```

Stworzyem ci.yml i skopiowałem Dockerfile

```
name: CI/CD Pipeline (Jenkins Port)

on:
  push:
    branches:
      - ino_dev
  pull_request:
    branches:
      - ino_dev

env:
  NETWORK_NAME: "app-network-${{ github.run_number }}"
  DEPLOY_NETWORK: "prod-app-network-${{ github.run_number }}"
  WORKING_DIR: "."

jobs:
  pipeline:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Build Docker Image
        run: |
          cd ${{ env.WORKING_DIR }}
          docker build -t realworld-app:latest .

      - name: Run API Tests
        run: |
          docker network create ${{ env.NETWORK_NAME }}
          docker run -d --name app-container --network ${{ env.NETWORK_NAME }} -e SERVER_ADDRESS=0.0.0.0 -e SERVER_PORT=8080 realworld-app:latest
          
          echo "Czekanie na start aplikacji..."
          TIMEOUT=60
          ELAPSED=0
          
          # Pętla typu 'waitUntil' sprawdzająca status HTTP 200
          until [ $(docker run --rm --network ${{ env.NETWORK_NAME }} curlimages/curl:8.19.0 -s -o /dev/null -w '%{http_code}' http://app-container:8080/api/tags || echo 0) -eq 200 ]; do
            if [ $ELAPSED -ge $TIMEOUT ]; then
              echo "Błąd: Aplikacja testowa nie wystartowała w 60 sekund."
              exit 1
            fi
            sleep 2
            ELAPSED=$((ELAPSED + 2))
          done
          
          # Wykonanie testów (t1, t2, t3)
          t1=$(docker run --rm --network ${{ env.NETWORK_NAME }} curlimages/curl -s -o /dev/null -w '%{http_code}' http://app-container:8080/api/tags)
          t2=$(docker run --rm --network ${{ env.NETWORK_NAME }} curlimages/curl -s -o /dev/null -w '%{http_code}' http://app-container:8080/api/articles)
          
          jsonPayload='{"user": {"username": "testuser", "email": "test@test.com", "password": "password123"}}'
          t3=$(docker run --rm --network ${{ env.NETWORK_NAME }} curlimages/curl -o /dev/null -w '%{http_code}' -X POST http://app-container:8080/api/users -H 'Content-Type: application/json' -d "${jsonPayload}")
          
          echo "Wyniki testów -> Tags: $t1, Articles: $t2, Register: $t3"
          
          if [ "$t1" = "200" ] && [ "$t2" = "200" ] && [ "$t3" = "201" ]; then
            echo "Testy przeszły pomyślnie!"
          else
            echo "Błąd w testach: Tags=${t1}, Articles=${t2}, Register=${t3}"
            exit 1
          fi

      - name: Cleanup API Tests Containers
        if: always()
        run: |
          docker stop app-container || true
          docker rm app-container || true
          docker network rm ${{ env.NETWORK_NAME }} || true

      - name: Deploy Application
        run: |
          docker network create ${{ env.DEPLOY_NETWORK }} || true
          docker stop realworld-prod || true
          docker rm realworld-prod || true
          
          docker run -d --name realworld-prod --network ${{ env.DEPLOY_NETWORK }} -p 8081:8080 -e SERVER_ADDRESS=0.0.0.0 -e SERVER_PORT=8080 realworld-app:latest
          
          echo "Czekanie na start aplikacji produkcyjnej..."
          TIMEOUT=60
          ELAPSED=0
          until [ $(docker run --rm --network ${{ env.DEPLOY_NETWORK }} curlimages/curl:8.19.0 -s -o /dev/null -w '%{http_code}' http://realworld-prod:8080/api/tags || echo 0) -eq 200 ]; do
            if [ $ELAPSED -ge $TIMEOUT ]; then
              echo "Błąd: Aplikacja produkcyjna nie wstała."
              exit 1
            fi
            sleep 2
            ELAPSED=$((ELAPSED + 2))
          done
          echo "Deployment udany."

      - name: Debug Deploy Failure
        if: failure()
        run: |
          echo "--- BŁĄD: Diagnostyka awarii kontenera produkcyjnego ---"
          docker logs realworld-prod || true
          docker ps -a --filter name=realworld-prod || true


      - name: Extract Jar File
        run: |
          docker create --name temp-container realworld-app:latest
          docker cp temp-container:/app/app.jar ./realworld-app.jar
          docker rm temp-container

      - name: Upload Artifact to GitHub
        uses: actions/upload-artifact@v4
        with:
          name: realworld-application-jar
          path: ./realworld-app.jar
          retention-days: 5
```

I zrobiem push na ga ino_dev


![scr1](./cw12/Screenshot_1.png)

![scr1](./cw12/Screenshot_2.png)

![scr1](./cw12/Screenshot_3.png)

Cały pipeline został przepisany z pipelinu Jenkins






