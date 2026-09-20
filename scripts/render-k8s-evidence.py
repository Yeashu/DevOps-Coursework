#!/usr/bin/env python3
"""Render selected real coursework transcripts as clearly labeled PNG evidence."""

from pathlib import Path
from textwrap import wrap

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
FONT = "/System/Library/Fonts/Menlo.ttc"
SOURCES = {
    "s9": "session9-k8s/evidence/cluster-lifecycle.txt",
    "pods": "session10-k8s-core-objects/evidence/pods.txt",
    "life": "session10-k8s-core-objects/evidence/pod-lifecycle.txt",
    "ctrl": "session10-k8s-core-objects/evidence/controllers.txt",
    "roll": "session10-k8s-core-objects/evidence/rolling-troubleshooting.txt",
    "blue": "session10-k8s-core-objects/evidence/blue-green-verified.txt",
    "canary": "session10-k8s-core-objects/evidence/canary-verified.txt",
    "recreate": "session10-k8s-core-objects/evidence/recreate.txt",
    "svc": "session-11-kubernetes-services/evidence/services.txt",
    "external": "session-11-kubernetes-services/evidence/external-access.txt",
    "config": "session-12-ingress-configmaps-secrets/evidence/config-and-secret.txt",
    "demo": "session-12-ingress-configmaps-secrets/evidence/full-demo-run.txt",
    "ingress": "session-12-ingress-configmaps-secrets/evidence/ingress-and-tls.txt",
    "hosts": "session-12-ingress-configmaps-secrets/evidence/hybrid-hosts-verified.txt",
    "cleanup": "session-12-ingress-configmaps-secrets/evidence/full-demo-cleanup.txt",
}
# Each range is inclusive and points to a saved, observed command transcript.
IMAGES = [
    ("session9-k8s/screenshots/01-version-check.png", "Session 9 · CLI versions", "s9", 1, 6),
    ("session9-k8s/screenshots/02-minikube-start.png", "Session 9 · Minikube start", "s9", 30, 46),
    ("session9-k8s/screenshots/03-minikube-status.png", "Session 9 · Cluster status and Ready node", "s9", 47, 57),
    ("session9-k8s/screenshots/04-minikube-stop.png", "Session 9 · Minikube stop", "s9", 58, 68),
    ("session10-k8s-core-objects/screenshots/01-cluster-health.png", "Session 10 · Cluster health", "s9", 7, 17),
    ("session10-k8s-core-objects/screenshots/02-pod-running.png", "Session 10 · Nginx Pod", "pods", 1, 9),
    ("session10-k8s-core-objects/screenshots/03-image-pull-error.png", "Session 10 · ImagePullBackOff", "life", 50, 68),
    ("session10-k8s-core-objects/screenshots/04-hello-lifecycle.png", "Session 10 · Completed batch Pod", "pods", 34, 44),
    ("session10-k8s-core-objects/screenshots/05-pod-lifecycle.png", "Session 10 · Pod lifecycle states", "life", 14, 33),
    ("session10-k8s-core-objects/screenshots/06-replicaset-statefulset.png", "Session 10 · ReplicaSet and StatefulSet", "ctrl", 7, 42),
    ("session10-k8s-core-objects/screenshots/07-daemonset.png", "Session 10 · DaemonSet", "ctrl", 43, 52),
    ("session10-k8s-core-objects/screenshots/08-rolling-update.png", "Session 10 · Rolling update and rollback", "roll", 1, 46),
    ("session10-k8s-core-objects/screenshots/09-troubleshooting.png", "Session 10 · Troubleshooting", "roll", 47, 69),
    ("session10-k8s-core-objects/screenshots/11-blue-green-cutover.png", "Session 10 · Blue-green cutover", "blue", 1, 22),
    ("session10-k8s-core-objects/screenshots/12-canary-traffic-split.png", "Session 10 · Canary traffic", "canary", 18, 36),
    ("session10-k8s-core-objects/screenshots/13-recreate-downtime-outage.png", "Session 10 · Recreate outage", "recreate", 1, 73),
    ("session-11-kubernetes-services/screenshots/02-clusterip.png", "Session 11 · ClusterIP and DNS", "svc", 1, 25),
    ("session-11-kubernetes-services/screenshots/03-nodeport.png", "Session 11 · NodePort", "external", 1, 22),
    ("session-11-kubernetes-services/screenshots/04-loadbalancer.png", "Session 11 · LoadBalancer tunnel", "external", 23, 48),
    ("session-11-kubernetes-services/screenshots/05-externalname.png", "Session 11 · ExternalName", "svc", 53, 70),
    ("session-11-kubernetes-services/screenshots/06-headless.png", "Session 11 · Headless Service", "svc", 71, 103),
    ("session-11-kubernetes-services/screenshots/07-selector-free.png", "Session 11 · Selector-free Service", "svc", 104, 114),
    ("session-11-kubernetes-services/screenshots/08-coredns.png", "Session 11 · CoreDNS resolver settings", "svc", 20, 26),
    ("session-11-kubernetes-services/screenshots/12-minikube-networking.png", "Session 11 · Docker-driver access", "external", 1, 48),
    ("session-12-ingress-configmaps-secrets/screenshots/01-configmap.png", "Session 12 · ConfigMap injection", "config", 1, 8),
    ("session-12-ingress-configmaps-secrets/screenshots/02-configmap-update.png", "Session 12 · ConfigMap live update", "config", 9, 18),
    ("session-12-ingress-configmaps-secrets/screenshots/03-secret.png", "Session 12 · Secret injection", "config", 19, 25),
    ("session-12-ingress-configmaps-secrets/screenshots/04-newline.png", "Session 12 · Base64 newline comparison", "config", 26, 29),
    ("session-12-ingress-configmaps-secrets/screenshots/06-combined-injection.png", "Session 12 · Combined app resources", "demo", 7, 30),
    ("session-12-ingress-configmaps-secrets/screenshots/08-ingress-controller.png", "Session 12 · Ingress controller", "ingress", 1, 10),
    ("session-12-ingress-configmaps-secrets/screenshots/09-local-routing.png", "Session 12 · Local Ingress routing", "ingress", 11, 16),
    ("session-12-ingress-configmaps-secrets/screenshots/10-path-routing.png", "Session 12 · Path routing", "ingress", 17, 22),
    ("session-12-ingress-configmaps-secrets/screenshots/11-virtual-hosts.png", "Session 12 · HTTPS virtual hosts", "hosts", 1, 10),
    ("session-12-ingress-configmaps-secrets/screenshots/12-hybrid-ingress.png", "Session 12 · Hybrid Ingress rules", "ingress", 53, 75),
    ("session-12-ingress-configmaps-secrets/screenshots/13-tls.png", "Session 12 · TLS handshake", "ingress", 35, 52),
    ("session-12-ingress-configmaps-secrets/screenshots/14-full-demo.png", "Session 12 · Full demo and cleanup", "cleanup", 1, 19),
]


def render(destination: Path, title: str, source: Path, first: int, last: int) -> None:
    original = source.read_text(encoding="utf-8", errors="replace").splitlines()
    selected = original[first - 1:last]
    assert selected, (source, first, last)
    lines = []
    for line in selected:
        lines.extend(wrap(line.expandtabs(4), width=160, replace_whitespace=False,
                          drop_whitespace=False, break_long_words=True) or [""])
    font = ImageFont.truetype(FONT, 18)
    small = ImageFont.truetype(FONT, 15)
    title_font = ImageFont.truetype(FONT, 21)
    width, line_height = 1840, 29
    height = 130 + len(lines) * line_height
    image = Image.new("RGB", (width, height), "#0d1117")
    draw = ImageDraw.Draw(image)
    draw.rectangle((0, 0, width, 58), fill="#21262d")
    for x, fill in ((26, "#ff5f56"), (54, "#ffbd2e"), (82, "#27c93f")):
        draw.ellipse((x, 22, x + 14, 36), fill=fill)
    draw.text((120, 17), title, font=title_font, fill="#f0f6fc")
    for index, line in enumerate(lines):
        fill = "#7ee787" if line.startswith("$ ") else "#c9d1d9"
        draw.text((26, 75 + index * line_height), line, font=font, fill=fill)
    caption = f"Rendered from recorded command output · {source.relative_to(ROOT)} lines {first}–{last}"
    draw.text((26, height - 34), caption, font=small, fill="#8b949e")
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.save(destination, format="PNG", optimize=True)


def main() -> None:
    for output, title, key, first, last in IMAGES:
        render(ROOT / output, title, ROOT / SOURCES[key], first, last)
    print(f"Rendered {len(IMAGES)} PNG evidence images")


if __name__ == "__main__":
    main()
