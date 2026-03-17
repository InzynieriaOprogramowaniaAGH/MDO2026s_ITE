ubuntu@myserver:~/MDO2026s_ITE$ sudo docker build   -t mdo-ite:sprawozdanie3-build 
  -f ITE/GCL3/YK424367/Sprawozdanie3/Dockerfile.build   .
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/

Sending build context to Docker daemon  24.34MB
Step 1/6 : FROM node:20
20: Pulling from library/node
2ea98bb5eec9: Already exists
efbce225727d: Already exists
bda59add4421: Already exists
5a8feb033ce1: Already exists
70503ccbdccc: Pulling fs layer
8b4abbe7f789: Pulling fs layer
8a3495667a5b: Pulling fs layer
b6ead51935f8: Pulling fs layer
b6ead51935f8: Waiting
70503ccbdccc: Verifying Checksum
70503ccbdccc: Download complete
70503ccbdccc: Pull complete
8a3495667a5b: Verifying Checksum
8a3495667a5b: Download complete
b6ead51935f8: Verifying Checksum
b6ead51935f8: Download complete
8b4abbe7f789: Verifying Checksum
8b4abbe7f789: Download complete
8b4abbe7f789: Pull complete
8a3495667a5b: Pull complete
b6ead51935f8: Pull complete
Digest: sha256:d38f72ebbc308224fe5666b13215048cdfe646b17b8828fd37fa18e70d84b6d5
Status: Downloaded newer image for node:20
 ---> e411ba256efc
Step 2/6 : WORKDIR /readme-aura
 ---> Running in 22a031006e88
 ---> Removed intermediate container 22a031006e88
 ---> 8c256a72fa27
Step 3/6 : RUN apt-get install -y git
 ---> Running in 12ab2de898dc
Reading package lists...
Building dependency tree...
Reading state information...
git is already the newest version (1:2.39.5-0+deb12u3).
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
 ---> Removed intermediate container 12ab2de898dc
 ---> f6094dcbdee5
Step 4/6 : RUN git clone https://github.com/collectioneur/readme-aura.git .
 ---> Running in 7324ea49f3bd
Cloning into '.'...
 ---> Removed intermediate container 7324ea49f3bd
 ---> 130d5b400796
Step 5/6 : RUN npm install
 ---> Running in 37c5c6eed0c2

added 224 packages, and audited 225 packages in 17s

95 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
npm notice
npm notice New major version of npm available! 10.8.2 -> 11.11.1
npm notice Changelog: https://github.com/npm/cli/releases/tag/v11.11.1
npm notice To update run: npm install -g npm@11.11.1
npm notice
 ---> Removed intermediate container 37c5c6eed0c2
 ---> 6fbff2d24db4
Step 6/6 : RUN npm run build
 ---> Running in 85d4d011c577

> readme-aura@0.1.11 build
> tsc

 ---> Removed intermediate container 85d4d011c577
 ---> 826a91c49af7
Successfully built 826a91c49af7
Successfully tagged mdo-ite:sprawozdanie3-build
ubuntu@myserver:~/MDO2026s_ITE$ sudo docker build   -t mdo-ite:sprawozdanie3-test   -f ITE/GCL3/YK424367/Sprawozdanie3/Dockerfile.test   .
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/

Sending build context to Docker daemon  24.34MB
Step 1/3 : FROM mdo-ite:sprawozdanie3-build
 ---> 826a91c49af7
Step 2/3 : WORKDIR /readme-aura
 ---> Running in 739154e35edd
 ---> Removed intermediate container 739154e35edd
 ---> e8819941c74d
Step 3/3 : CMD ["npm", "test"]
 ---> Running in 8f5f8e6e00e9
 ---> Removed intermediate container 8f5f8e6e00e9
 ---> 41a220eea8ca
Successfully built 41a220eea8ca
Successfully tagged mdo-ite:sprawozdanie3-test
ubuntu@myserver:~/MDO2026s_ITE$ sudo docker run --rm mdo-ite:sprawozdanie3-test

> readme-aura@0.1.11 test
> vitest run


 RUN  v4.1.0 /readme-aura

 ✓ src/tests/renderer.test.ts (28 tests) 47ms
 ✓ src/tests/init.test.ts (13 tests) 114ms
 ✓ src/tests/parser.test.ts (7 tests) 13ms
 ✓ src/tests/github.test.ts (12 tests) 3ms
 ✓ src/tests/templates.test.ts (12 tests) 3ms

 Test Files  5 passed (5)
      Tests  72 passed (72)
   Start at  08:07:52
   Duration  771ms (transform 92ms, setup 0ms, import 320ms, tests 180ms, environment 0ms)
