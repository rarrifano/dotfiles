---
name: k8s-debug
description: Kubernetes debugging — crashlooping pods, pending scheduling, OOMKilled, failed deployments, service connectivity, resource pressure, and RBAC errors. Use when something is broken or misbehaving in a Kubernetes cluster.
---

# k8s-debug — Kubernetes Debugging Skill

## Guardrails

- Never run `kubectl delete` without explicit confirmation.
- Never edit live resources with `kubectl edit` without warning about drift from source of truth.
- Always identify the namespace before running commands — default is rarely production.

## Triage by symptom

### Pod not starting / CrashLoopBackOff

```bash
kubectl get pod <pod> -n <ns> -o wide
kubectl describe pod <pod> -n <ns>
kubectl logs <pod> -n <ns> --previous
kubectl logs <pod> -n <ns> -c <container>   # multi-container pod
```

Look in `describe` output for:
- `Exit Code` — 1=app error, 137=OOMKilled, 139=segfault
- `Reason: OOMKilled` → increase memory limit
- `Liveness probe failed` → probe misconfigured or app too slow to start
- `Back-off restarting failed container` → check logs --previous

### Pod stuck in Pending

```bash
kubectl describe pod <pod> -n <ns>
kubectl get events -n <ns> --sort-by='.lastTimestamp' | tail -20
```

Look for:
- `Insufficient cpu/memory` → node pressure; check `kubectl top nodes`
- `no nodes available to schedule` → node selector / taint mismatch
- `PVC not bound` → storage class issue; check `kubectl get pvc -n <ns>`

### Deployment not rolling out

```bash
kubectl rollout status deployment/<name> -n <ns>
kubectl rollout history deployment/<name> -n <ns>
kubectl describe deployment <name> -n <ns>
```

Rollback if needed:
```bash
kubectl rollout undo deployment/<name> -n <ns>
```

### Service not reachable

```bash
# Check endpoints — if empty, label selector is wrong
kubectl get endpoints <svc> -n <ns>
kubectl describe svc <svc> -n <ns>

# Test from inside the cluster
kubectl run debug --image=busybox --rm -it --restart=Never -- \
  wget -qO- http://<svc>.<ns>.svc.cluster.local:<port>
```

### RBAC errors

```bash
# Check what a serviceaccount can do
kubectl auth can-i <verb> <resource> \
  --as=system:serviceaccount:<ns>:<sa> -n <ns>

# Check existing bindings
kubectl get rolebindings,clusterrolebindings -n <ns> \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.subjects[*].name}{"\n"}{end}'
```

### Resource pressure

```bash
kubectl top nodes
kubectl top pods -n <ns> --sort-by=memory
kubectl describe node <node> | grep -A10 "Allocated resources"
```

## Output format

After running commands, report as:
```
FINDING   <what was found>
CAUSE     <likely root cause>
FIX       <exact command or config change>
RISK      <any risk in the proposed fix>
```
