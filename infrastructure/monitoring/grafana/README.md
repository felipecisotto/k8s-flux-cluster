# Grafana com Flux - Configuração de Dashboards Efêmeros via Sidecar

Este diretório contém a configuração do Grafana utilizando Flux e Helm para garantir a persistência dos dashboards via repositório Git, permitindo o uso de containers efêmeros com o sidecar do Grafana.

## Estrutura de Diretórios

```text
grafana/
├── dashboards/
│   ├── json/                     # Diretório contendo os arquivos JSON dos dashboards (referência)
│   ├── datasources.yaml          # Configuração das fontes de dados
│   └── kustomization.yaml        # Kustomize com configMapGenerator
├── deployment.yaml               # HelmRelease do Grafana com configuração do sidecar
├── ingress.yaml                  # Configuração de ingress
├── kustomization.yaml            # Kustomize principal
├── README.md                     # Esta documentação
└── repository.yaml               # Referência ao repositório Helm
```

## Como Adicionar um Novo Dashboard

Para adicionar um novo dashboard ao Grafana, siga os passos abaixo:

1. Exporte o dashboard do Grafana em formato JSON
2. Salve o arquivo JSON no diretório `dashboards/json/` com um nome significativo (ex: `meu-dashboard.json`)
3. Edite o arquivo JSON para:
   - Remover o ID fixo (use `"id": null`)
   - Ajustar as referências de datasource para uid correto (ex: `"uid": "prometheus"`)
4. Adicione o arquivo ao `configMapGenerator` no arquivo `dashboards/kustomization.yaml`:

    ```yaml
    configMapGenerator:
    - name: grafana-json-dashboards
        namespace: monitoring
        options:
        labels:
            grafana_dashboard: "1"
        disableNameSuffixHash: true
        files:
        - json/financial-backend-golden-signals.json
        - json/meu-dashboard.json    # Adicione seu novo dashboard aqui
    ```

5. Faça commit das alterações e deixe o Flux sincronizar com o cluster

## Configuração do Sidecar

A configuração utiliza o sidecar oficial do Grafana para descobrir automaticamente dashboards e datasources configurados como ConfigMaps no cluster:

```yaml
sidecar:
  datasources:
    enabled: true
    label: grafana_datasource
    labelValue: "1"
    searchNamespace: ALL
  dashboards:
    enabled: true
    label: grafana_dashboard
    labelValue: "1"
    searchNamespace: ALL
    provider:
      foldersFromFilesStructure: false
```

O sidecar monitora ConfigMaps com a label `grafana_dashboard: "1"` e os disponibiliza automaticamente para o Grafana, eliminando a necessidade de volumes personalizados.

## Benefícios dessa Abordagem

1. **Simplicidade**: Os dashboards são armazenados como ConfigMaps no Kubernetes
2. **Facilidade de manutenção**: Basta adicionar novos arquivos JSON ao configMapGenerator
3. **Versionamento**: Os dashboards são versionados junto com o código
4. **Containers efêmeros**: O Grafana pode ser reiniciado a qualquer momento sem perder configurações
5. **Automação**: O Flux garante que os dashboards sempre sejam aplicados no cluster
6. **Descoberta dinâmica**: O sidecar detecta automaticamente novos dashboards sem necessidade de reiniciar o Grafana

## Uso do Kustomize ConfigMapGenerator com Sidecar

Esta configuração combina o `configMapGenerator` do Kustomize com o sidecar do Grafana:

1. O Kustomize gera ConfigMaps a partir dos arquivos JSON com a label `grafana_dashboard: "1"`
2. O sidecar do Grafana detecta esses ConfigMaps e os disponibiliza automaticamente
3. O Grafana carrega os dashboards sem precisar de volumes montados manualmente

Isso oferece um fluxo de trabalho GitOps ideal:

- Adicione ou altere dashboards no repositório
- O Flux aplica as alterações no cluster
- O sidecar detecta os novos ConfigMaps e atualiza o Grafana

## Dicas Importantes

1. Remova o campo `id` fixo do dashboard ou defina-o como `null` para evitar conflitos
2. Verifique se os `uid` das fontes de dados estão corretos (use "prometheus" em vez de variáveis)
3. Se você tem muitos dashboards, considere organizar em subdiretórios dentro de `json/`
4. Se precisar organizar dashboards em pastas dentro do Grafana, isso pode ser feito no próprio JSON do dashboard

## Observações

- O sidecar do Grafana descobre automaticamente dashboards definidos como ConfigMaps
- As atualizações feitas pela UI do Grafana não serão persistidas - sempre faça as alterações via repositório Git
- Para alterações de emergência, você pode editar o dashboard na UI e depois exportá-lo para o repositório
