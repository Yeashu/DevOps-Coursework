# Session 16: CI/CD & GitHub Actions

**Student:** Prabhav Semwal · **Enrollment:** 24BCS10358


The calculator has unit tests, an HTTP API, a Docker image and a GitHub Actions pipeline. [The root workflow](../.github/workflows/coursework.yml) runs the complete exercise; nested workflow files are reference copies because GitHub discovers workflows only in the repository root's `.github/workflows/` directory.

```bash
cd session16-cicd
python -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
python -m pytest -v --cov=app
bash build.sh
docker build -t coursework-calculator .
docker run --rm -p 5001:5001 coursework-calculator
```

## Pipeline concepts

CI integrates changes and checks build/test results before publication. CD delivers the passing image to a runnable environment. A workflow is the event-triggered YAML definition; a job executes steps on a runner. Jobs can run in parallel, and `needs` expresses dependency gates. A step either executes shell commands (`run`) or calls a reusable action (`uses`). The hosted lab's CD stage creates a temporary cluster, deploys the built image and verifies its health endpoint.

## Secrets and artifacts

The registry job uses GitHub's automatically supplied `GITHUB_TOKEN` as a secret and grants only the needed package permission. Credentials are passed through standard input and never printed. Build files, test reports, transcripts, and screenshots are uploaded as workflow artifacts. Artifacts store outputs of an execution; the repository stores versioned source and selected evidence.

## Build, test, publish and deploy

The runner executes the unit suite, runs the build script, builds the container, verifies HTTP health, publishes a commit-tagged GHCR image, loads the same image into Minikube, deploys it and checks readiness and HTTP. The workflow summary and saved transcripts establish the successful execution. The deployment uses a temporary coursework namespace.

[GitHub Actions concepts](https://docs.github.com/en/actions/get-started/understand-github-actions)

## Recorded execution evidence

These PNGs render genuine saved command output. Full transcripts are linked below.

![local-unit-tests-01](screenshots/local-unit-tests-01.png)

[Commands and output: local-unit-tests.txt](evidence/local-unit-tests.txt)
