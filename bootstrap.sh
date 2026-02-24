#!/bin/bash

set -euxo pipefail

k() {
  kubectl --context k3d-homelab "$@"
}

k3d cluster create --config ./k3d.yaml

k get namespace argocd || k create namespace argocd
k apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

k -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
