#!/usr/bin/env bash

set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fundamentals_output="$repo_root/docker-fundamentals/evidence/docker-fundamentals-output.txt"
images_output="$repo_root/docker-images/evidence/docker-images-output.txt"
mkdir -p "$(dirname "$fundamentals_output")" "$(dirname "$images_output")"

containers=(
  nodejs-hello python-hello java-hello apache-hello react-hello nginx-hello
  multi-stage-app
)
cleanup() {
  docker rm -f "${containers[@]}" >/dev/null 2>&1 || true
}
trap cleanup EXIT
cleanup

wait_for_url() {
  local url="$1"
  for _ in {1..30}; do
    curl --silent --fail "$url" && return 0
    sleep 1
  done
  return 1
}

{
  echo "$ date --iso-8601=seconds"
  date --iso-8601=seconds
  echo "$ docker version"
  docker version --format 'Docker client {{.Client.Version}}, server {{.Server.Version}}'

  echo
  echo "$ docker build -t coursework-nodejs ./nodejs-app"
  docker build --quiet -t coursework-nodejs "$repo_root/docker-fundamentals/nodejs-app"
  docker run -d --name nodejs-hello -p 3001:3000 coursework-nodejs
  echo "Node.js response:"
  wait_for_url http://localhost:3001

  echo
  echo "$ docker build -t coursework-python ./python-app"
  docker build --quiet -t coursework-python "$repo_root/docker-fundamentals/python-app"
  docker run -d --name python-hello -p 5001:5000 coursework-python
  echo "Python response:"
  wait_for_url http://localhost:5001

  echo
  echo "$ docker build -t coursework-java ./java-app"
  docker build --quiet -t coursework-java "$repo_root/docker-fundamentals/java-app"
  docker run -d --name java-hello -p 8081:8080 coursework-java
  echo "Java response:"
  wait_for_url http://localhost:8081

  echo
  echo "$ docker build -t coursework-apache ./Apache-app"
  docker build --quiet -t coursework-apache "$repo_root/docker-fundamentals/Apache-app"
  docker run -d --name apache-hello -p 8082:80 coursework-apache
  echo "Apache response:"
  wait_for_url http://localhost:8082

  echo
  echo "$ docker build -t coursework-react ./React-app"
  docker build --quiet -t coursework-react "$repo_root/docker-fundamentals/React-app"
  docker run -d --name react-hello -p 8083:80 coursework-react
  echo "React response:"
  wait_for_url http://localhost:8083

  echo
  echo "$ docker build -t coursework-nginx ./nginx-app"
  docker build --quiet -t coursework-nginx "$repo_root/docker-fundamentals/nginx-app"
  docker run -d --name nginx-hello -p 8084:80 coursework-nginx
  echo "Nginx response:"
  wait_for_url http://localhost:8084

  echo
  echo "$ docker ps"
  docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}'
} > "$fundamentals_output" 2>&1

{
  echo "$ date --iso-8601=seconds"
  date --iso-8601=seconds
  echo "$ docker build -t coursework-multi-stage ./multi-stage-app"
  docker build --quiet -t coursework-multi-stage "$repo_root/docker-images/multi-stage-app"
  docker run -d --name multi-stage-app -p 8080:3000 coursework-multi-stage
  echo "$ curl --fail http://localhost:8080"
  wait_for_url http://localhost:8080
  echo
  echo "$ docker ps --filter name=multi-stage-app"
  docker ps --filter name=multi-stage-app --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}'
  echo
  echo "Three deployed application types:"
  for name in nodejs-hello python-hello java-hello; do
    docker ps --filter "name=^${name}$" --format '{{.Names}} -> {{.Image}} ({{.Ports}})'
  done
} > "$images_output" 2>&1

echo "Docker application evidence captured."
