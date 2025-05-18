# Prometheus Monitoring

Esta pasta contém a configuração do Prometheus para monitoramento do cluster Kubernetes e outros alvos externos.

## Estrutura de Arquivos

```text
prometheus/
├── deployment.yaml           # HelmRelease do Prometheus e AlertManager
├── kubelet-scrape.yaml       # Configuração para scrape dos kubelet metrics
├── app-alerts.yaml           # Regras de alertas para aplicações, Proxmox e Kubernetes
├── kustomization.yaml        # Kustomize para organizar os recursos
└── README.md                 # Esta documentação
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
```

## AlertManager

O AlertManager foi configurado para enviar notificações para o Telegram quando os alertas forem disparados. A configuração está diretamente no arquivo `deployment.yaml` para facilitar a aplicação.

### Configuração do Telegram

Para configurar o bot do Telegram:

1. Converse com o [@BotFather](https://t.me/botfather) no Telegram
2. Use o comando `/newbot` para criar um novo bot
3. Siga as instruções e obtenha o token do bot
4. Crie um grupo no Telegram e adicione o bot a ele
5. Obtenha o Chat ID enviando uma mensagem para o grupo e acessando:

   ```text
   https://api.telegram.org/bot<SEU_TOKEN>/getUpdates
   ```

6. Atualize os valores `bot_token` e `chat_id` diretamente na seção `alertmanager.config` do arquivo `deployment.yaml`

### Testando Alertas

Para testar se o AlertManager está enviando notificações corretamente para o Telegram, você pode usar a API RESTful do AlertManager:

1. Configure um port-forward para o serviço do AlertManager:

   ```bash
   kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093
   ```

2. Envie um alerta de teste usando curl:

   ```bash
   curl -XPOST http://localhost:9093/api/v2/alerts \
     -H "Content-Type: application/json" \
     -d '[{
       "startsAt": "'$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")'",
       "endsAt": "",
       "annotations": {
         "summary": "Teste de alerta manual",
         "description": "Este é um alerta enviado manualmente via API para testar a notificação no Telegram"
       },
       "labels": {
         "alertname": "TesteManual",
         "severity": "warning",
         "service": "api-teste",
         "job": "teste-api"
       }
     }]'
   ```

3. Você também pode acessar a interface web do AlertManager em:
   - [AlertManager](https://alertmanager.felipecisotto.com.br)

### Regras de Alertas

#### Alertas para Aplicações

As regras de alertas foram configuradas de forma genérica para monitorar qualquer aplicação que exporte métricas OpenTelemetry. Os alertas identificam qual `job` e `service` está com problema nas notificações.

##### Métricas HTTP

| Alerta | Descrição | Severidade |
|--------|-----------|------------|
| HTTPLatencyHigh | Latência p95 > 500ms por 5min | Warning |
| HTTPLatencyCritical | Latência p95 > 1000ms por 2min | Critical |
| HTTPErrorRateHigh | Taxa de erros 5XX > 5% por 2min | Warning |
| HTTPErrorRateCritical | Taxa de erros 5XX > 10% por 1min | Critical |
| HighRequestRate | Taxa de requisições > 100/s por 5min | Warning |

#### Alertas para Proxmox

Foram configurados alertas para monitorar o uso de recursos no host Proxmox e suas VMs.

##### Host Proxmox

| Alerta | Descrição | Severidade |
|--------|-----------|------------|
| ProxmoxHostHighCPUUsage | Uso de CPU > 80% por 10min | Warning |
| ProxmoxHostCriticalCPUUsage | Uso de CPU > 95% por 5min | Critical |
| ProxmoxHostHighMemoryUsage | Uso de memória > 80% por 10min | Warning |
| ProxmoxHostCriticalMemoryUsage | Uso de memória > 95% por 5min | Critical |
| ProxmoxHostHighDiskUsage | Uso de disco > 95% por 30min | Warning |
| ProxmoxHostCriticalDiskUsage | Uso de disco > 99% por 15min | Critical |

##### VMs Proxmox

| Alerta | Descrição | Severidade |
|--------|-----------|------------|
| ProxmoxVMHighCPUUsage | Uso de CPU > 90% por 10min | Warning |
| ProxmoxVMHighMemoryUsage | Uso de memória > 90% por 10min | Warning |
| ProxmoxVMHighDiskUsage | Uso de disco > 90% por 30min | Warning |

#### Alertas para Kubernetes

Foram configurados alertas para monitorar o estado dos pods, recursos dos nós e componentes do sistema Kubernetes.

##### Alertas para Pods

| Alerta | Descrição | Severidade |
|--------|-----------|------------|
| KubernetesPodRestartingTooMuch | Pod reiniciou > 5 vezes na última hora | Warning |
| KubernetesPodNotHealthy | Pod em estado Failed/Pending/Unknown por > 5min | Warning |
| KubernetesContainerWaiting | Container em estado waiting por > 1h | Warning |

##### Alertas para Recursos de Nós

| Alerta | Descrição | Severidade |
|--------|-----------|------------|
| KubernetesNodeHighCPUUsage | Uso de CPU do nó > 80% por 5min | Warning |
| KubernetesNodeHighMemoryUsage | Uso de memória do nó > 80% por 5min | Warning |
| KubernetesNodeDiskPressure | Uso de disco do nó > 85% por 5min | Warning |

##### Alertas para Componentes do Sistema

| Alerta | Descrição | Severidade |
|--------|-----------|------------|
| KubernetesNamespaceManyFailedPods | > 5 pods Failed/Pending em um namespace por 10min | Warning |
| KubernetesPersistentVolumeClaimPending | PVC pendente por > 1h | Warning |
| KubernetesEtcdHighNumberOfLeaderChanges | > 3 mudanças de líder no etcd na última hora | Critical |
| KubernetesDeploymentReplicasMismatch | Deployment com réplicas indisponíveis por > 15min | Warning |

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

## Como Adicionar Novos Alertas

Para adicionar novas regras de alertas:

1. Edite o arquivo `app-alerts.yaml`
2. Adicione uma nova regra na seção apropriada
3. Aplique as alterações com Flux ou kubectl

Exemplo de como adicionar um novo alerta:

```yaml
- alert: NovoAlerta
  expr: <expressão_prometheus>
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Resumo do alerta"
    description: "Descrição detalhada do alerta"
```
