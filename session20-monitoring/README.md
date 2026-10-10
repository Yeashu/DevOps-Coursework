# Session 20: Monitoring, Observability & GitOps

**Student:** Prabhav Semwal · **Enrollment:** 24BCS10358


The exercise runs an instrumented Flask app, Prometheus, Node Exporter, Grafana and Argo CD in an ephemeral Minikube environment.

```bash
kubectl create namespace coursework-s20
kubectl -n coursework-s20 apply -f monitoring/
kubectl -n coursework-s20 get pods,services
kubectl -n coursework-s20 port-forward service/grafana 13000:3000
```

## Monitoring demo

[Prometheus](monitoring/prometheus.yaml) scrapes application request metrics and node resource metrics, evaluates the [ApplicationUnavailable rule](monitoring/prometheus.yaml), and exposes a query API. [Grafana](monitoring/grafana.yaml) provisions a dashboard with application health, HTTP request count, CPU utilization and memory utilization. Anonymous access is restricted to Viewer and is used only in this temporary lab.

The runner queries each metric, prints application logs, scales the application to zero, waits for the alert to fire, restores the application and verifies the alert clears. Node metrics describe the Minikube node; they are not per-Pod resource measurements. `kubectl top pods` separately shows Pod CPU and memory.

## Observability

| Pillar | What it tells us | Common tools |
| --- | --- | --- |
| Metrics | Numerical trends such as request rate, error rate, CPU and memory | Prometheus, Grafana, Metrics Server |
| Logs | Discrete events with application context | kubectl logs, Loki, Elasticsearch |
| Traces | The path and latency of one request across services | OpenTelemetry, Jaeger, Tempo |

Monitoring detects known symptoms; observability helps investigate unfamiliar failures by relating these signals. In Kubernetes, inspect workload health, node pressure, container restarts, events, application logs and request metrics together. Trace instrumentation propagates a trace ID between services so logs and spans can be correlated; the demonstration here records metrics and logs.

## GitOps demo

[The Argo CD Application](argocd-application.yaml) points to [gitops/app.yaml](gitops/app.yaml) in this repository. Git holds the declared ConfigMap, Deployment and Service. Argo CD continuously compares those manifests with live objects and automatically synchronizes drift. `prune` removes objects deleted from Git; `selfHeal` repairs changes made directly in the cluster.

The runner waits for `Synced` and `Healthy`, changes the ConfigMap directly to introduce drift, asks Argo CD to refresh, and verifies the Git-defined page content is restored. It also requests the page through the Kubernetes Service. Source changes should be committed and reviewed in Git before the controller applies them.

[Prometheus alerting](https://prometheus.io/docs/alerting/latest/overview/) · [Argo CD auto-sync](https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/) · [Kubernetes monitoring](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/)

## Mini project: change desired state in Git

The GitOps path includes a Namespace, a two-replica Deployment, a Service and the page ConfigMap. The lab commits a change from two to three replicas in Git, refreshes Argo CD and verifies three ready Pods. It then scales the live Deployment to one replica and verifies self-healing restores the Git-defined three replicas. The Git change and direct-cluster drift are separate checks.
