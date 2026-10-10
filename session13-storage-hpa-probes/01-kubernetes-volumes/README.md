# Kubernetes volumes

**Student:** Prabhav Semwal · **Enrollment:** 24BCS10358


| Volume or object | Lifetime and purpose | Practical example |
| --- | --- | --- |
| emptyDir | Lives for one Pod; survives a container restart and disappears when that Pod is removed | [emptydir-demo.yaml](emptydir-demo.yaml) |
| hostPath | Uses a path on the assigned node; data is tied to that node and needs careful access control | [hostpath-demo.yaml](hostpath-demo.yaml) |
| PersistentVolume | Cluster-scoped storage supplied by an administrator or provisioner | [static-storage.yaml](static-storage.yaml) |
| PersistentVolumeClaim | Namespace-scoped request for capacity and access mode; binds to a suitable PV | [static-storage.yaml](static-storage.yaml) |
| StorageClass | Defines provisioner, parameters, binding mode, and reclaim policy | `kubectl get storageclass -o yaml` |
| Dynamic provisioning | Creates a PV in response to a claim; a consumer may be needed with WaitForFirstConsumer | [dynamic-storage.yaml](dynamic-storage.yaml) |

A `Retain` PV keeps its underlying data after claim deletion and needs administrative cleanup. A `Delete` policy lets the provisioner remove backing storage. ReadWriteOnce means one node can mount the volume read/write; it is not a guarantee that only one Pod can mount it.

Minikube hostPath storage is suitable for this single-node exercise. A multi-node system needs a storage driver and storage accessible from the nodes that run the workload. See the [session execution evidence](../README.md#recorded-execution-evidence).
