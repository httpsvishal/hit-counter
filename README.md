# hitcounter: a Kubernetes lab for minikube

A small Node API that counts visits in Redis. It runs the same way on
minikube (local) and on a production cluster such as EKS; only the
Kustomize overlay changes.

## Layout

    app/                  Node API + Dockerfile
    k8s/base/             manifests shared by every environment
    k8s/overlays/minikube local settings (NodePort, default storage)
    k8s/overlays/eks      production-style settings (ALB, gp3, PDB ...)
    scripts/              smoke test, load balancing check, load test
    Makefile              shortcuts for every step

## Quick start

    make up        # create the cluster
    make build     # build the image inside minikube
    make deploy    # apply k8s/overlays/minikube
    make status    # pods, services, PVC, HPA
    make test      # smoke test
    make spread    # which Pod answered each request?
    make load      # drive the HPA
    make down      # delete the cluster

Requirements: minikube, kubectl, and a container driver (Docker).
