#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

sudo k3d cluster create --config confs/config.yaml

# Namespaces: argocd and dev
sudo kubectl apply -f confs/default/

# Argo CD (upstream install + --insecure patch)
sudo kubectl apply --server-side -k confs/argocd/
sudo kubectl wait --for condition=established crd/applications.argoproj.io --timeout=120s
sudo kubectl -n argocd rollout status deploy/argocd-server --timeout=300s

sudo kubectl apply -f confs/ingress/
sudo kubectl apply -f confs/argocd/argocd-app.yaml

echo
echo "Argo CD UI : http://localhost:8081  (user: admin)"
echo -n "Password   : "
sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d || true
echo
echo "App        : http://localhost:8888"
