#!/bin/bash

sudo k3d cluster create --config ./config/config.yaml

until sudo kubectl get namespace argocd >/dev/null 2>&1; do
  sleep 1
done

sudo kubectl apply --server-side -k ./config/argocd/. -n argocd
sudo kubectl apply -f ./config/ingress/.
sudo kubectl apply -f ./config/argocd/argocd-app.yaml
