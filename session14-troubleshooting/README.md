# Session 14: Kubernetes Troubleshooting

**Student:** Prabhav Semwal · **Enrollment:** 24BCS10358


```bash
kubectl create namespace coursework-s14
kubectl -n coursework-s14 apply -f labs/broken-crash.yaml
kubectl -n coursework-s14 describe pod crash-demo
kubectl -n coursework-s14 logs crash-demo --previous
kubectl -n coursework-s14 delete pod crash-demo
kubectl -n coursework-s14 apply -f labs/fixed-crash.yaml
```

The exercise creates faults in `coursework-s14`, collects symptoms and events, fixes each root cause, and verifies recovery. NetworkPolicy checks require an enforcing CNI; the hosted lab uses Calico.

## Troubleshooting commands

| Command | What it establishes |
| --- | --- |
| kubectl get, get -o wide | Current object state, Pod IP, and node placement |
| kubectl describe | Configuration, conditions, scheduling decisions, and events |
| kubectl logs, logs --previous | Current and previous container output |
| kubectl exec | The container's filesystem, environment, and connectivity |
| kubectl events | Recent warnings and normal lifecycle events |
| kubectl explain | The API schema and meaning of a field |
| kubectl top | Measured CPU and memory; requires Metrics Server |

## Problems, diagnosis and fixes

| Problem | Investigation and root cause | Fix and verification |
| --- | --- | --- |
| CrashLoopBackOff | Logs show an intentional exit; restart count rises | Replace the startup command; wait for Ready |
| ErrImagePull / ImagePullBackOff | Events show a nonexistent image tag; the initial pull failure transitions to backoff | Use a valid image; verify image-demo becomes Ready |
| Pending | FailedScheduling event reports an impossible CPU request | Lower the request and verify placement |
| ContainerCreating | FailedMount reports a missing ConfigMap | Create the ConfigMap; verify its mounted file |
| Service connectivity | Service selector does not match Pod labels; EndpointSlice has no backend | Correct the selector; verify HTTP succeeds |
| DNS | An incorrect Service name returns lookup failure | Query the actual Service FQDN and verify its address |
| Pod networking | Default-deny ingress policy blocks an HTTP client | Allow the labelled client and verify traffic resumes |
| Configuration | A mounted ConfigMap contains an incorrect application mode | Correct the value and wait for the projected file to update |

## Mini project

[broken.yaml](mini-project/broken.yaml) contains two independent faults: an incorrect readiness path and an incorrect Service selector. Correcting only one leaves the application unavailable. [fixed.yaml](mini-project/fixed.yaml) repairs both. The transcript records diagnosis, Pod readiness, endpoints, and an HTTP check after repair.

[Kubernetes troubleshooting](https://kubernetes.io/docs/tasks/debug/debug-application/) · [Network policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

## Mini-project questions

The [broken image Pod](mini-project/broken-image.yaml) requests a tag that does not exist. The first pull attempt reports ErrImagePull; repeated failures produce ImagePullBackOff. `kubectl describe pod project-broken-pod` and its Events identify the registry error. Correct the image tag after collecting those observations, then verify the replacement is Ready.

| Question | Answer |
| --- | --- |
| What does get show? | A compact view of object state and readiness. |
| How is describe different? | It adds detailed configuration, conditions and Events. |
| Why use logs? | To inspect application startup and runtime failures. |
| When use exec? | To inspect files, environment and connectivity inside a running container. |
| What is CrashLoopBackOff? | A restart delay after a container repeatedly exits. |
| What is ImagePullBackOff? | A retry delay after the node cannot fetch the image. |
| Why Pending? | Scheduling or resource/storage requirements cannot yet be satisfied. |
| Why no Service endpoints? | Selectors match no Pods, Pods are unready, or the backend has not been configured. |
| Selector versus labels? | The selector identifies Pods whose labels match the Service's required key/value pairs. |
| What is Kubernetes DNS? | Cluster name resolution that lets applications find Services and selected Pod identities. |
