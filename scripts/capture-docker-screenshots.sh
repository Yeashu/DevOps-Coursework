#!/usr/bin/env bash

set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
playwright_image="mcr.microsoft.com/playwright:v1.55.0-noble"
work_dir="$repo_root/.evidence-work/screenshots"
mkdir -p "$work_dir"
mkdir -p "$repo_root/docker-fundamentals/evidence/screenshots"
mkdir -p "$repo_root/docker-images/evidence/screenshots"
mkdir -p "$repo_root/docker-networking/evidence/screenshots"

containers=(
  capture-node capture-python capture-java capture-apache capture-react
  capture-nginx capture-multi-stage capture-host-apache capture-bind-nginx
  coursework-browser
)
cleanup() {
  docker rm -f "${containers[@]}" >/dev/null 2>&1 || true
}
trap cleanup EXIT
cleanup

wait_for_url() {
  local url="$1"
  for _ in {1..30}; do
    curl --silent --fail "$url" >/dev/null && return 0
    sleep 1
  done
  return 1
}

screenshot() {
  local url="$1"
  local output="$2"
  local slug="${output##*/}"
  local frame="$work_dir/${slug%.png}-browser-frame.html"
  printf '%s\n' \
    '<!doctype html><html><head><meta charset="utf-8"><style>' \
    '*{box-sizing:border-box}html,body{width:100%;height:100%;margin:0;overflow:hidden;font-family:Arial,sans-serif;background:#fff}' \
    '.browser{height:52px;padding:9px 14px;display:flex;align-items:center;gap:12px;background:#dee1e6;border-bottom:1px solid #bdc1c6}' \
    '.dots{font-size:18px;letter-spacing:3px;color:#5f6368}.address{height:34px;line-height:34px;flex:1;padding:0 14px;border-radius:17px;background:#fff;color:#202124;font:14px/34px Arial,sans-serif;box-shadow:inset 0 0 0 1px #c7cacf}' \
    'iframe{display:block;width:100%;height:calc(100% - 52px);border:0;background:#fff}</style></head><body>' \
    "<div class=\"browser\"><span class=\"dots\">● ● ●</span><div class=\"address\">URL: $url</div></div>" \
    "<iframe src=\"$url\"></iframe></body></html>" > "$frame"
  echo "Chromium screenshot: $url -> $output"
  docker exec coursework-browser npx -y playwright@1.55.0 screenshot \
    --browser chromium --viewport-size=1280,720 \
    "file:///work/.evidence-work/screenshots/$(basename "$frame")" "/work/$output"
}

terminal_screenshot() {
  local input="$1"
  local output="$2"
  local dimensions width height
  dimensions="$(sed -n '1s/.*width="\([0-9]*\)" height="\([0-9]*\)".*/\1 \2/p' "$input")"
  read -r width height <<< "$dimensions"
  echo "Chromium terminal screenshot: $input (${width}x${height}) -> $output"
  docker exec coursework-browser timeout 30 npx -y playwright@1.55.0 screenshot \
    --browser chromium --viewport-size="$width,$height" \
    "file:///work/${input#"$repo_root/"}" "/work/$output"
}

docker run -d --name capture-node -p 3001:3000 coursework-nodejs >/dev/null
docker run -d --name capture-python -p 5001:5000 coursework-python >/dev/null
docker run -d --name capture-java -p 8081:8080 coursework-java >/dev/null
docker run -d --name capture-apache -p 8082:80 coursework-apache >/dev/null
docker run -d --name capture-react -p 8083:80 coursework-react >/dev/null
docker run -d --name capture-nginx -p 8084:80 coursework-nginx >/dev/null
docker run -d --name capture-multi-stage -p 8080:3000 coursework-multi-stage >/dev/null
docker run -d --name capture-host-apache --network host httpd:2.4-alpine >/dev/null

bind_site="$repo_root/.evidence-work/screenshot-bind-site"
mkdir -p "$bind_site"
printf '<h1>Hello students</h1>\n' > "$bind_site/index.html"
docker run -d --name capture-bind-nginx -p 8090:80 \
  --mount "type=bind,source=$bind_site,target=/usr/share/nginx/html,readonly" \
  nginx:1.29-alpine >/dev/null

for url in \
  http://localhost:3001 http://localhost:5001 http://localhost:8081 \
  http://localhost:8082 http://localhost:8083 http://localhost:8084 \
  http://localhost:8080 http://localhost:80 http://localhost:8090; do
  wait_for_url "$url"
done

python3 "$repo_root/scripts/render-transcript.py" \
  "$repo_root/docker-fundamentals/evidence/docker-fundamentals-output.txt" \
  "$work_dir/docker-fundamentals-terminal.svg" --title "Docker Fundamentals — build, run, curl, docker ps"
python3 "$repo_root/scripts/render-transcript.py" \
  "$repo_root/docker-images/evidence/docker-images-output.txt" \
  "$work_dir/docker-images-terminal.svg" --title "Docker Images — multi-stage build on port 8080"
python3 "$repo_root/scripts/render-transcript.py" \
  "$repo_root/docker-networking/evidence/docker-networking-output.txt" \
  "$work_dir/docker-networking-terminal.svg" --title "Docker Networking and bind-mount evidence"

docker run -d --name coursework-browser --network host \
  -v "$repo_root:/work" -w /work "$playwright_image" sleep 1d >/dev/null

screenshot http://localhost:3001 docker-fundamentals/evidence/screenshots/nodejs.png
screenshot http://localhost:5001 docker-fundamentals/evidence/screenshots/python.png
screenshot http://localhost:8081 docker-fundamentals/evidence/screenshots/java.png
screenshot http://localhost:8082 docker-fundamentals/evidence/screenshots/apache.png
screenshot http://localhost:8083 docker-fundamentals/evidence/screenshots/react.png
screenshot http://localhost:8084 docker-fundamentals/evidence/screenshots/nginx.png
screenshot http://localhost:8080 docker-images/evidence/screenshots/multi-stage-app.png
screenshot http://localhost:80 docker-networking/evidence/screenshots/host-network-apache.png
screenshot http://localhost:8090 docker-networking/evidence/screenshots/bind-mount-before.png

bind_container_before="$(docker inspect capture-bind-nginx --format '{{.Id}}')"
printf '<h1>Hello students - bind mount updated</h1>\n' > "$bind_site/index.html"
wait_for_url http://localhost:8090
screenshot http://localhost:8090 docker-networking/evidence/screenshots/bind-mount-after.png
bind_container_after="$(docker inspect capture-bind-nginx --format '{{.Id}}')"
test "$bind_container_before" = "$bind_container_after"

terminal_screenshot "$work_dir/docker-fundamentals-terminal.svg" \
  docker-fundamentals/evidence/screenshots/docker-terminal.png
terminal_screenshot "$work_dir/docker-images-terminal.svg" \
  docker-images/evidence/screenshots/docker-terminal.png
terminal_screenshot "$work_dir/docker-networking-terminal.svg" \
  docker-networking/evidence/screenshots/docker-terminal.png

file "$repo_root"/docker-*/evidence/screenshots/*.png
echo "Headless Chromium screenshots captured."
