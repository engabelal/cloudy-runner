# Changelog

All notable changes to Cloudy Runner will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- SECURITY.md for vulnerability reporting
- GitHub labels configuration
- CHANGELOG.md template
- Example use cases directory
- Workflow badges in README

### Changed
- Switched from parallel to sequential downloads for reliability
- Improved workflow label handling

### Fixed
- Docker build failures due to shell backgrounding issues
- GitHub workflow label creation errors

---

## [1.0.0] - 2025-12-25

### Added
- Initial release of Cloudy Runner
- Multi-architecture support (amd64, arm64)
- **Infrastructure as Code Tools**:
  - Terraform 1.9.8
  - Ansible 10.7.0
- **Kubernetes Tools**:
  - kubectl v1.31.14
  - Helm v3.19.4
  - Kustomize v5.8.0
- **Cloud CLIs**:
  - AWS CLI v2
  - Azure CLI (via apt)
- **Node.js Ecosystem**:
  - Node.js 22.21.1 LTS
  - npm, yarn, pnpm
- **Utilities**:
  - yq v4.50.1
  - jq, git, curl, wget, make
- GitHub Actions workflows:
  - `docker-build.yml` - Multi-arch image builds
  - `version-checker.yml` - Weekly version monitoring
  - `security-refresh.yml` - Weekly security scans
- BuildKit cache optimizations
- Comprehensive documentation

[Unreleased]: https://github.com/engabelal/cloudy-runner/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/engabelal/cloudy-runner/releases/tag/v1.0.0
