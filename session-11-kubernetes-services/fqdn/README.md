# Kubernetes FQDN and Service DNS

A fully qualified domain name identifies a name through the complete DNS hierarchy. In Kubernetes, a normal Service is commonly addressed as `<service>.<namespace>.svc.<cluster-domain>`. The default cluster domain is `cluster.local`, but administrators can configure a different value.

| Example | Meaning |
| --- | --- |
| `web-service-clusterip` | Short name resolved through the Pod's namespace search suffix |
| `web-service-clusterip.default` | Service name qualified with its namespace |
| `web-service-clusterip.default.svc.cluster.local` | Complete Service DNS name in the default cluster domain |
| `web-stateful-0.web-service-headless.default.svc.cluster.local` | Stable StatefulSet Pod name through its headless Service |

A Pod in another namespace should qualify the Service name to avoid accidentally selecting a same-named local Service. Normal Service DNS resolves to the virtual Service IP; EndpointSlices identify the backing ready Pods. Headless Service DNS returns backing Pod addresses instead of a virtual ClusterIP. ExternalName returns a DNS alias.

```bash
kubectl exec curl-client -- cat /etc/resolv.conf
kubectl exec curl-client -- nslookup web-service-clusterip.default.svc.cluster.local
kubectl exec curl-client -- wget -qO- http://web-service-clusterip.default.svc.cluster.local:8080
```

The resolver's search list and `ndots` setting affect how short names are expanded. A trailing dot requests an absolute DNS name. See [observed Service and DNS output](../evidence/services.txt) and the [session README](../README.md).

[Kubernetes DNS reference](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
