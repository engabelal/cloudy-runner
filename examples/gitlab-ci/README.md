# GitLab CI Examples

Example pipelines using Cloudy Runner.

## .gitlab-ci.yml

Complete Infrastructure Pipeline:

```yaml
image: engabelal/cloudy-runner:latest

stages:
  - validate
  - plan
  - deploy

variables:
  TF_ROOT: terraform/

# Terraform Validation
validate:
  stage: validate
  script:
    - cd $TF_ROOT
    - terraform init -backend=false
    - terraform validate
    - terraform fmt -check
  only:
    changes:
      - terraform/**/*

# Terraform Plan
plan:
  stage: plan
  script:
    - cd $TF_ROOT
    - terraform init
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - $TF_ROOT/tfplan
    expire_in: 1 hour
  only:
    - merge_requests

# Terraform Apply
deploy:
  stage: deploy
  script:
    - cd $TF_ROOT
    - terraform init
    - terraform apply -auto-approve
  environment:
    name: production
  only:
    - main
  when: manual

# Kubernetes Deployment
deploy-k8s:
  stage: deploy
  script:
    - echo "$KUBECONFIG" | base64 -d > /tmp/kubeconfig
    - export KUBECONFIG=/tmp/kubeconfig
    - helm upgrade --install myapp ./helm-chart --wait
  environment:
    name: production
  only:
    - main
```

## Key Features

- **Multi-stage pipeline**: Validate → Plan → Deploy
- **Manual approval**: Production deployment requires manual trigger
- **Artifact passing**: Plan file passed between stages
- **Change detection**: Only runs on relevant file changes
