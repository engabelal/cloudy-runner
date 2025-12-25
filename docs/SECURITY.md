# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |
| 1.x.x   | :white_check_mark: |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability in Cloudy Runner, please report it responsibly.

### How to Report

1. **DO NOT** create a public GitHub issue for security vulnerabilities
2. Email: **eng.abelal@gmail.com** with subject: `[SECURITY] Cloudy Runner Vulnerability`
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 7 days
- **Resolution Timeline**: Depends on severity
  - Critical: 24-48 hours
  - High: 7 days
  - Medium: 30 days
  - Low: Next release

### Security Measures

This project implements several security practices:

- **Weekly Security Scans**: Automated Trivy scans every Sunday
- **Base Image Updates**: Ubuntu 24.04 LTS with regular patches
- **Dependency Monitoring**: Dependabot for GitHub Actions dependencies
- **Version Pinning**: All tool versions explicitly pinned in `versions.env`

### Security Scanning

You can scan the image yourself:

```bash
# Using Trivy
docker run --rm aquasec/trivy:latest image engabelal/cloudy-runner:latest

# Using Docker Scout
docker scout cves engabelal/cloudy-runner:latest
```

### Acknowledgments

We appreciate responsible disclosure and will acknowledge security researchers in our release notes (with permission).
