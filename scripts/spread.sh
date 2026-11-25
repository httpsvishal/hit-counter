#!/usr/bin/env bash
# Call the Service from INSIDE the cluster and count which Pod answered.
set -euo pipefail
NS=hitcounter

# shellcheck disable=SC2016  # the quotes are meant to protect $i for the Pod's shell
kubectl -n "$NS" run spread --rm -i --restart=Never \
  --image=curlimages/curl -- sh -c '
    for i in $(seq 1 20); do
      curl -s http://api/ | sed "s/.*\"pod\":\"\([^\"]*\)\".*/\1/"
    done' | grep '^api-' | sort | uniq -c
