#!/usr/bin/env bash
# Wait for the app to be ready, then call it a few times.
set -euo pipefail
NS=hitcounter

kubectl -n "$NS" rollout status statefulset/redis --timeout=180s
kubectl -n "$NS" rollout status deployment/api --timeout=180s

kubectl -n "$NS" port-forward svc/api 8080:80 >/dev/null 2>&1 &
PF=$!
trap 'kill $PF 2>/dev/null || true' EXIT
sleep 2

for _ in 1 2 3 4 5; do
  curl -fsS localhost:8080/
  echo
done
echo "smoke test passed"
