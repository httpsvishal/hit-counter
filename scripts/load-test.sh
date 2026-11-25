#!/usr/bin/env bash
# Generate CPU load from inside the cluster so the HPA reacts.
# In another terminal run:  kubectl -n hitcounter get hpa -w
set -euo pipefail
NS=hitcounter
DURATION="${1:-120}"

kubectl -n "$NS" run load --rm -i --restart=Never \
  --image=node:22-alpine -- \
  npx --yes autocannon -c 40 -d "$DURATION" http://api/burn
