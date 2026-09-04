#!/usr/bin/env bash

set -euo pipefail

containers=(
  coursework-frontend
  coursework-backend
  coursework-database
  coursework-host-apache
  coursework-bind-nginx
)
networks=(frontend-net app-net database-net)

cleanup() {
  docker rm -f "${containers[@]}" >/dev/null 2>&1 || true
  docker network rm "${networks[@]}" >/dev/null 2>&1 || true
}
trap cleanup EXIT
cleanup

echo "=== Three-network container topology ==="
for network in "${networks[@]}"; do
  docker network create "$network"
done

docker run -d --name coursework-frontend --network frontend-net alpine:3.22 sleep 1d
docker network connect app-net coursework-frontend

docker run -d --name coursework-backend --network app-net alpine:3.22 \
  sh -c "while true; do printf 'HTTP/1.1 200 OK\r\nContent-Length: 18\r\n\r\nHello from backend' | nc -l -p 8080; done"
docker network connect database-net coursework-backend

docker run -d --name coursework-database --network database-net \
  -e MYSQL_ALLOW_EMPTY_PASSWORD=yes mysql:8.4

echo
echo "Frontend networks:"
docker inspect coursework-frontend --format '{{range $name, $_ := .NetworkSettings.Networks}}{{$name}} {{end}}'
echo "Backend networks:"
docker inspect coursework-backend --format '{{range $name, $_ := .NetworkSettings.Networks}}{{$name}} {{end}}'
echo "Database networks:"
docker inspect coursework-database --format '{{range $name, $_ := .NetworkSettings.Networks}}{{$name}} {{end}}'

echo
echo "Frontend to backend (expected success):"
docker exec coursework-frontend wget -qO- http://coursework-backend:8080
echo
echo "Backend to database (expected success):"
for _ in {1..30}; do
  docker exec coursework-backend nc -z -w 2 coursework-database 3306 && break
  sleep 1
done
docker exec coursework-backend nc -z -v -w 2 coursework-database 3306
echo
echo "Frontend to database (expected isolation):"
if docker exec coursework-frontend nc -z -w 2 coursework-database 3306; then
  echo "ERROR: isolated containers unexpectedly connected"
  exit 1
else
  echo "Expected result: frontend cannot resolve or reach the database directly."
fi

echo
echo "=== Apache host-network demonstration ==="
docker run -d --name coursework-host-apache --network host httpd:2.4-alpine
for _ in {1..20}; do
  curl --silent --fail http://localhost:80 >/dev/null && break
  sleep 1
done
curl --fail http://localhost:80
docker inspect coursework-host-apache --format 'Network mode: {{.HostConfig.NetworkMode}}'

echo
echo "=== Nginx bind-mount demonstration ==="
demo_site="$PWD/.evidence-work/bind-site"
mkdir -p "$demo_site"
printf '<h1>Hello students</h1>\n' > "$demo_site/index.html"
docker run -d --name coursework-bind-nginx -p 8090:80 \
  --mount "type=bind,source=$demo_site,target=/usr/share/nginx/html,readonly" \
  nginx:1.29-alpine
for _ in {1..20}; do
  curl --silent --fail http://localhost:8090 >/dev/null && break
  sleep 1
done
container_id_before="$(docker inspect coursework-bind-nginx --format '{{.Id}}')"
echo "Before host file change:"
curl --fail http://localhost:8090

printf '<h1>Hello students - bind mount updated</h1>\n' > "$demo_site/index.html"
container_id_after="$(docker inspect coursework-bind-nginx --format '{{.Id}}')"
echo "After host file change:"
curl --fail http://localhost:8090
test "$container_id_before" = "$container_id_after"
echo "Container ID unchanged: $container_id_after"
