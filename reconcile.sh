#!/bin/bash

# Obter commits do repositório
COMMITS=$(git log --reverse --format='%H')

for COMMIT in $COMMITS; do
  # Fazer checkout do commit específico
  git checkout $COMMIT

  # Forçar o reconcile no Flux
  flux reconcile kustomization <nome-da-kustomization> --with-source

  # Esperar até que o reconcile seja bem-sucedido
  sleep 30
done
