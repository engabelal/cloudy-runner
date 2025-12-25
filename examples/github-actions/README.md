# GitHub Actions Examples

Example workflows using Cloudy Runner.

## terraform-deploy.yml

Complete Terraform deployment workflow:

```yaml
name: Terraform Deploy

on:
  push:
    branches: [main]
    paths:
      - 'terraform/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    container:
      image: engabelal/cloudy-runner:latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_DEFAULT_REGION: us-west-2
        run: |
          cd terraform
          terraform init
          terraform plan -out=tfplan
          terraform apply -auto-approve tfplan
```

## kubernetes-deploy.yml

Kubernetes deployment with Helm:

```yaml
name: K8s Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    container:
      image: engabelal/cloudy-runner:latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Deploy to K8s
        env:
          KUBECONFIG_DATA: ${{ secrets.KUBECONFIG }}
        run: |
          echo "$KUBECONFIG_DATA" | base64 -d > /tmp/kubeconfig
          export KUBECONFIG=/tmp/kubeconfig

          helm upgrade --install myapp ./helm-chart \
            --namespace production \
            --wait --timeout=300s
```

## multi-cloud.yml

Multi-cloud infrastructure management:

```yaml
name: Multi-Cloud Sync

on:
  workflow_dispatch:

jobs:
  sync:
    runs-on: ubuntu-latest
    container:
      image: engabelal/cloudy-runner:latest

    steps:
      - uses: actions/checkout@v4

      - name: AWS Infrastructure
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          cd terraform/aws
          terraform init && terraform apply -auto-approve

      - name: Azure Infrastructure
        env:
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
        run: |
          cd terraform/azure
          terraform init && terraform apply -auto-approve
```
