# Docker Images and Multi-Stage Builds

Name: **Prabhav Semwal**  
Enrollment number: **24BCS10358**

## Multi-stage Dockerfile

The [multi-stage application](multi-stage-app/) follows the example supplied
in the course repository. Its builder stage installs the complete dependency
set. The production stage copies only the manifest and server, then installs
production dependencies. This separates build work from the smaller runtime
image.

The app listens on container port 3000. Publishing it as `8080:3000`
satisfies the requirement to access it on host port 8080:

```bash
docker build -t coursework-multi-stage ./multi-stage-app
docker run -d --name multi-stage-app -p 8080:3000 coursework-multi-stage
curl --fail http://localhost:8080
docker ps --filter name=multi-stage-app
```

Expected application text:

```text
Hello World from Docker multi-stage build
```

## Three application types

I also deployed three different application stacks by building the Node.js,
Python/Flask, and Java folders from
[Docker Fundamentals](../docker-fundamentals/README.md). Their language
runtimes, ports, and HTTP output are distinct, and each was verified with
`curl --fail`.

Real build, run, page, and `docker ps` results:
[`evidence/docker-images-output.txt`](evidence/docker-images-output.txt).

![Docker Images terminal evidence](evidence/docker-images-output.svg)
