# Prometheus Monitoring

Esta pasta contém a configuração do Prometheus para monitoramento do cluster Kubernetes e outros alvos externos.

## Estrutura de Arquivos

```text
prometheus/
├── deployment.yaml         # HelmRelease do Prometheus
├── kubelet-scrape.yaml     # Configuração para scrape dos kubelet metrics
├── kustomization.yaml      # Kustomize para organizar os recursos
└── README.md               # Esta documentação
```

## Configurações Externas

### Proxmox VE Monitoring

Foi configurado um job de scrape para coletar métricas do Proxmox VE:

```yaml
additionalScrapeConfigs:
  - job_name: 'proxmox'
    static_configs:
      - targets:
        - 192.168.0.199:9221  # Proxmox VE node com PVE exporter
    metrics_path: /pve
    params:
      module: [default]
      cluster: ['1']
      node: ['1']
    basic_auth:
      username: "seu_usuario"
      password: "sua_senha"
```

### Autenticação

As credenciais para o Proxmox VE estão hardcoded no arquivo `deployment.yaml`. Em um ambiente de produção, seria melhor usar Secrets do Kubernetes para armazenar as credenciais.

## Como Adicionar Novos Alvos (Targets)

Para adicionar novos alvos de scrape no Prometheus:

1. Edite o arquivo `deployment.yaml`
2. Adicione um novo job na seção `additionalScrapeConfigs`
3. Aplique as alterações com Flux ou kubectl

Exemplo de como adicionar um novo alvo:

```yaml
additionalScrapeConfigs:
  - job_name: 'novo-alvo'
    static_configs:
      - targets:
        - novo-alvo:9100
    metrics_path: /metrics
```
