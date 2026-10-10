# CoreDNS

CoreDNS is the DNS server commonly used in Kubernetes. Its Kubernetes plugin watches Service and endpoint information through the API and answers cluster DNS queries. The `kube-dns` Service exposes DNS to Pods; kubelet configures their resolver settings. External queries are usually forwarded to configured upstream resolvers.

```text
Pod resolver → kube-dns Service → CoreDNS
                               ├─ Kubernetes plugin: cluster Service/Pod records
                               └─ Forward plugin: external DNS resolver
```

The `coredns` ConfigMap in `kube-system` contains a `Corefile`. Typical plugins include `kubernetes` for cluster records, `forward` for upstream requests, `cache`, `health`, `ready`, `errors`, and `loop`. A cache improves lookup latency but can briefly retain an older answer according to its TTL.

```bash
kubectl -n kube-system get pods -l k8s-app=kube-dns
kubectl -n kube-system get service kube-dns
kubectl -n kube-system get configmap coredns -o yaml
kubectl -n kube-system logs -l k8s-app=kube-dns --tail=50
kubectl exec curl-client -- cat /etc/resolv.conf
kubectl exec curl-client -- nslookup kubernetes.default.svc.cluster.local
kubectl exec curl-client -- nslookup api.github.com
```

For a DNS failure, first verify the name and namespace, then inspect resolver configuration, CoreDNS readiness, Service endpoints, logs, and network policies. If cluster names resolve but external names fail, investigate forwarding and upstream connectivity. If DNS succeeds but HTTP fails, check the destination Service's ports and ready endpoints separately.

[Observed DNS output](../evidence/services.txt) · [CoreDNS Kubernetes plugin](https://coredns.io/plugins/kubernetes/) · [Kubernetes DNS debugging](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/)
