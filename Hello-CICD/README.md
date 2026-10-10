# Session 17: Complete CI/CD & DevSecOps

**Student:** Prabhav Semwal · **Enrollment:** 24BCS10358

The submission for this assignment is maintained in the standalone **Hello-CICD** repository:

- [Complete Session 17 README](https://github.com/Yeashu/Hello-CICD/blob/main/session17/README.md)
- [Application, tests and Dockerfile](https://github.com/Yeashu/Hello-CICD)
- [Security configuration and gated workflow](https://github.com/Yeashu/Hello-CICD/blob/main/.github/workflows/devsecops.yml)
- [Pipeline runs and execution evidence](https://github.com/Yeashu/Hello-CICD/actions)

```text
Code → Build → Unit tests → SAST → SCA → Secret scan → Docker build
     → Image scan → Security gate → Registry push → Kubernetes deployment
```

The standalone workflow records scanner and deployment results and generates screenshots for the submission. Its README documents the tools, failure policies, registry authentication and Kubernetes verification.

The Flask application in this coursework folder includes Prometheus instrumentation for [Session 20](../session20-monitoring/README.md). The coursework workflow builds that image for the monitoring lab; CI/CD and DevSecOps delivery execute in the standalone repository.
