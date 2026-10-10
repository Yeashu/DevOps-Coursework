# Session 17: Complete CI/CD & DevSecOps

**Student:** Prabhav Semwal · **Enrollment:** 24BCS10358


The instructor's Flask dashboard is used as the application. It has eight unit tests, a non-root production Docker image and Kubernetes health checks. The [root coursework workflow](../.github/workflows/coursework.yml) executes the gated pipeline and saves its outputs.

```text
Build → Unit tests → SAST → SCA → Secret scan → Docker build
      → Container image scan → Security gate → GHCR push → Kubernetes deployment
```

## Security checks and gates

| Stage | Tool | Gate |
| --- | --- | --- |
| Unit testing | pytest + pytest-cov | All application tests must pass |
| SAST | Bandit | High-severity/high-confidence findings fail |
| SCA | pip-audit | Known dependency vulnerabilities fail |
| Secret scanning | Gitleaks | Detected embedded credentials fail |
| Image scanning | Trivy | CRITICAL image findings fail |
| Deployment | kubectl rollout + HTTP probe | Ready Pods and healthy response required |

The scanner commands return nonzero on policy violations, and the script uses `set -euo pipefail`, so failed gates stop publication. A synthetic vulnerable fixture demonstrates that the SAST gate rejects unsafe shell execution. A synthetic credential fixture demonstrates that secret scanning rejects an embedded credential. Fixtures remain in temporary runner directories and are removed.

The application selects random greeting text; Bandit's B311 finding is suppressed only on that non-security use. The container listener's B104 finding is similarly documented. Application debug mode is disabled. The Trivy report retains findings, and the gate threshold is CRITICAL.

## Registry and Kubernetes

GitHub's automatic registry token is supplied through standard input. The image is tagged with the source commit SHA. The runner loads the tested image into its temporary Minikube cluster, applies [Deployment](k8s/deployment.yaml) and [Service](k8s/service.yaml), waits for rollout, then calls `/health` and the calculator API through port forwarding. Pulling into the ephemeral cluster from the built image avoids assuming the GHCR package has public pull visibility.

```bash
cd Hello-CICD
pip install -r requirements-dev.txt
pytest -v --cov=app
bandit -r app -lll -iii
pip-audit -r requirements.txt
docker build -t coursework-devsecops:lab .
```

[Bandit](https://bandit.readthedocs.io/) · [pip-audit](https://github.com/pypa/pip-audit) · [Gitleaks](https://github.com/gitleaks/gitleaks) · [Trivy](https://trivy.dev/)
