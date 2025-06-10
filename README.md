# K8s Flux Cluster - Homelab

Este repositório contém as configurações do cluster Kubernetes gerenciado pelo Flux CD para o ambiente homelab.

## 📋 Visão Geral

O cluster está organizado em duas principais categorias:
- **Apps**: Aplicações de usuário final
- **Infrastructure**: Serviços de infraestrutura e monitoramento

## 🚀 Aplicações (Apps)

### Financial System
- **Serviço**: Financial Backend
  - **Namespace**: financial
  - **Contexto**: API backend para sistema financeiro pessoal
  - **Imagem**: `ghcr.io/felipecisotto/financial-backend:latest`
  - **Porta**: 8080 (HTTP), 9464 (OpenTelemetry)
  - **Recursos**: CPU: 100m-500m, Memory: 128Mi-512Mi

- **Serviço**: Financial Frontend
  - **Namespace**: financial
  - **Contexto**: Interface web para sistema financeiro pessoal
  - **Imagem**: `ghcr.io/felipecisotto/financial-frontend:latest`
  - **Porta**: 3000
  - **Recursos**: CPU: 100m-200m, Memory: 128Mi-256Mi

### Smart Review System
- **Serviço**: Smart Review Backend
  - **Namespace**: smart-review
  - **Contexto**: API backend para sistema de reviews inteligentes
  - **Imagem**: `registry.felipecisotto.com.br/smart-review-backend:1.0.1`
  - **Porta**: 3000
  - **Versão**: 1.0.1

- **Serviço**: Smart Review Shopify App
  - **Namespace**: smart-review
  - **Contexto**: Aplicação Shopify para integração com sistema de reviews
  - **Imagem**: `ghcr.io/smart-review/smart-review-shopify-app:1.0.0`
  - **Versão**: 1.0.0

### Heimdall
- **Serviço**: Heimdall Dashboard
  - **Namespace**: apps
  - **Contexto**: Dashboard de aplicações e links organizados
  - **Versão**: 8.X (Helm Chart)
  - **Tipo**: HelmRelease
  - **Armazenamento**: 500Mi PVC

### N8N
- **Serviço**: N8N Workflow Automation
  - **Namespace**: apps
  - **Contexto**: Plataforma de automação de workflows e integrações
  - **Imagem**: `n8nio/n8n:latest`
  - **Porta**: 5678
  - **Recursos**: Memory: 250Mi-500Mi
  - **Armazenamento**: PVC para dados persistentes

### Home Assistant
- **Serviço**: Home Assistant
  - **Namespace**: apps
  - **Contexto**: Plataforma de automação residencial e IoT
  - **Imagem**: `homeassistant/home-assistant:stable`
  - **Porta**: 8123
  - **Configuração**: Host Network habilitado
  - **Armazenamento**: PVC para configurações

### Uptime Kuma
- **Serviço**: Uptime Kuma
  - **Namespace**: apps
  - **Contexto**: Monitoramento de uptime e status de serviços
  - **Imagem**: `louislam/uptime-kuma:latest`
  - **Porta**: 3001
  - **Armazenamento**: PVC para dados de monitoramento

## 🏗️ Infraestrutura

### Monitoramento

#### Prometheus
- **Serviço**: Prometheus Stack
  - **Namespace**: monitoring
  - **Contexto**: Coleta de métricas e alertas do cluster
  - **Versão**: 58.x (kube-prometheus-stack)
  - **Tipo**: HelmRelease
  - **Retenção**: 15 dias
  - **Armazenamento**: 10Gi PVC
  - **Recursos**: CPU: 100m-1000m, Memory: 256Mi-1Gi
  - **Integração**: AlertManager com notificações Telegram

#### Grafana
- **Serviço**: Grafana
  - **Namespace**: monitoring
  - **Contexto**: Visualização de métricas e dashboards
  - **Versão**: 6.56.0 (Helm Chart)
  - **Tipo**: HelmRelease
  - **Credenciais**: admin/admin
  - **Configuração**: Dashboards automáticos via sidecar

#### Loki & Promtail
- **Serviço**: Loki Stack
  - **Namespace**: monitoring
  - **Contexto**: Agregação e consulta de logs do cluster
  - **Componentes**: Loki (servidor) + Promtail (agente)

### Segurança

#### Sealed Secrets
- **Serviço**: Sealed Secrets Controller
  - **Namespace**: kube-system
  - **Contexto**: Criptografia de secrets para armazenamento seguro no Git
  - **Versão**: 2.16.2 (Helm Chart)
  - **Tipo**: HelmRelease
  - **Repositório**: Bitnami

#### Cert Manager
- **Serviço**: Certificate Manager
  - **Namespace**: cert-manager (implícito)
  - **Contexto**: Gerenciamento automático de certificados TLS
  - **Componentes**: Certificate, Issuer

### Utilitários

#### Reflector
- **Serviço**: Reflector
  - **Namespace**: kube-system (implícito)
  - **Contexto**: Replicação de secrets e configmaps entre namespaces

## 📁 Estrutura do Repositório

```
├── apps/                    # Aplicações de usuário
│   ├── financial/          # Sistema financeiro (backend + frontend)
│   ├── smart-review/       # Sistema de reviews (backend + shopify-app)
│   ├── heimdall/           # Dashboard de aplicações
│   ├── n8n/               # Automação de workflows
│   ├── home-assistant/     # Automação residencial
│   ├── uptime-kuma/       # Monitoramento de uptime
│   └── namespace/         # Definições de namespaces
├── infrastructure/         # Serviços de infraestrutura
│   ├── monitoring/        # Stack de monitoramento (Prometheus, Grafana, Loki)
│   ├── sealed-secrets/    # Controlador de secrets criptografados
│   ├── cert-manager/      # Gerenciamento de certificados
│   ├── reflector/         # Replicação de recursos
│   └── namespaces/        # Namespaces de infraestrutura
└── clusters/
    └── homelab/           # Configurações específicas do cluster
```

## 🔧 Tecnologias Utilizadas

- **Kubernetes**: Orquestração de containers
- **Flux CD**: GitOps e continuous deployment
- **Helm**: Gerenciamento de pacotes Kubernetes
- **Kustomize**: Customização de manifests Kubernetes
- **Traefik**: Ingress controller e proxy reverso
- **Prometheus Stack**: Monitoramento e alertas
- **Grafana**: Visualização de dados
- **Loki**: Agregação de logs

## 🚀 Deploy e Gerenciamento

O cluster utiliza **Flux CD** para implementar GitOps, onde:
- Todas as mudanças são feitas via commits neste repositório
- O Flux monitora o repositório e aplica automaticamente as mudanças
- Os recursos são organizados usando Kustomize e Helm
- Secrets são gerenciados com Sealed Secrets para segurança

## 📊 Monitoramento

- **Métricas**: Coletadas pelo Prometheus com retenção de 15 dias
- **Logs**: Agregados pelo Loki via Promtail
- **Visualização**: Dashboards no Grafana
- **Alertas**: Configurados no AlertManager com notificações via Telegram
- **Uptime**: Monitorado pelo Uptime Kuma

## 🔐 Segurança

- Certificados TLS gerenciados automaticamente pelo Cert Manager
- Secrets criptografados com Sealed Secrets
- Isolamento por namespaces
- Recursos limitados por quotas e limits
