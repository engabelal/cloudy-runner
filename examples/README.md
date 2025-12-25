# Example Use Cases

This directory contains example configurations for using Cloudy Runner in various CI/CD scenarios.

## Contents

| Example | Description |
|---------|-------------|
| [github-actions/](github-actions/) | GitHub Actions workflow examples |
| [gitlab-ci/](gitlab-ci/) | GitLab CI/CD pipeline examples |
| [local-dev/](local-dev/) | Local development scripts |

## Quick Start

### GitHub Actions

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    container:
      image: engabelal/cloudy-runner:latest
    steps:
      - uses: actions/checkout@v4
      - run: terraform apply -auto-approve
```

### Docker Run

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.aws:/root/.aws:ro \
  engabelal/cloudy-runner:latest
```

## Adding New Examples

1. Create a subdirectory for your CI/CD platform
2. Add working configuration files
3. Include a README explaining the example
4. Submit a pull request
