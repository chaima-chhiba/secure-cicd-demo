# 🔐 Full DevSecOps Pipeline

A production-grade DevSecOps project combining a containerized app, Kubernetes deployment, Terraform infrastructure, automated security scanning, and live monitoring with Prometheus and Grafana.

## 🏗️ Project Structure

```
secure-cicd-demo/
├── app/
│   ├── app.py                    # Flask application with Prometheus metrics
│   └── requirements.txt          # Python dependencies
├── Dockerfile                    # Hardened container definition
├── k8s/
│   ├── deployment.yaml           # Kubernetes deployment (2 replicas)
│   ├── service.yaml              # NodePort service with Prometheus port
│   └── servicemonitor.yaml       # Prometheus scrape config
├── terraform/
│   ├── main.tf                   # Kubernetes resources as code
│   ├── variables.tf              # Configurable variables
│   └── outputs.tf                # Infrastructure outputs
├── .trivyignore                  # Accepted risk exceptions
├── .github/
│   └── workflows/
│       └── security-scan.yml     # Full CI/CD security pipeline
└── README.md
```

## 🛡️ Security Pipeline

Every push triggers 6 automated security jobs in this order:

```
Gitleaks (secrets)
    ├── Semgrep SAST (code scan)
    ├── OWASP Dependency-Check (dependencies)
    └── Trivy (docker image scan)
              ├── Generate SBOM
              └── Push to Docker Hub (only if all scans pass)
                        └── Deploy to Kubernetes
```

| Tool | What it checks | Fails pipeline if |
|------|-----------------|-------------------|
| **Gitleaks** | Secrets and API keys in code and git history | Any secret is found |
| **Semgrep** | Python source code vulnerabilities (SAST) | High severity issue found |
| **OWASP Dependency-Check** | Known CVEs in Python packages via NIST NVD | CVSSv3 score >= 9.0 |
| **Trivy** | Docker image OS-level vulnerabilities | CRITICAL CVE with a fix available |
| **Syft SBOM** | Generates software bill of materials | Never fails, always produces report |
| **Docker Hub Push** | Pushes verified image to registry | Only runs if all scans pass |

## 🚀 Local Setup

### Prerequisites
- Docker Desktop
- Python 3.12+
- Git
- Minikube
- kubectl
- Terraform
- Helm

### Run the app locally with Docker

```bash
git clone https://github.com/chaima-chhiba/secure-cicd-demo.git
cd secure-cicd-demo
docker build -t secure-cicd-demo .
docker run -p 5000:5000 secure-cicd-demo
```

Visit `http://localhost:5000`:

```json
{"message": "Secure CI/CD Demo", "status": "ok"}
```

Visit `http://localhost:5000/metrics` to see Prometheus metrics.

## ☸️ Kubernetes Deployment

### Start Minikube

```bash
minikube start
```

### Deploy with kubectl

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/servicemonitor.yaml
```

### Or deploy with Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Access the app

```bash
minikube service secure-cicd-demo-service
```

### Check running pods

```bash
kubectl get pods
kubectl get services
```

Expected output:

```
NAME                                READY   STATUS    RESTARTS   AGE
secure-cicd-demo-xxx-xxx            1/1     Running   0          1m
secure-cicd-demo-xxx-xxx            1/1     Running   0          1m
```

## 📊 Monitoring

### Install Prometheus + Grafana

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace
```

### Access Grafana

```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
```

Open `http://localhost:3000`
- Username: `admin`
- Password: run `kubectl get secret -n monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d`

### Access Prometheus

```bash
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090
```

Open `http://localhost:9090`

### Pre-built dashboards available in Grafana

- Kubernetes / Compute Resources / Cluster — cluster-wide CPU and memory
- Kubernetes / Compute Resources / Pod — per-pod resource usage
- Kubernetes / API server — API server metrics
- Alertmanager / Overview — alert status

## 🔬 How the Pipeline Works

### 1. Gitleaks — Secrets Detection
Scans the entire git history using `fetch-depth: 0` for accidentally committed credentials, API keys, or tokens. Runs first — if secrets are found, nothing else executes.

### 2. Semgrep — SAST
Static analysis of Python source code using the `p/python` ruleset. Detects insecure patterns like SQL injection, unsafe deserialization, and hardcoded credentials. Results published to Semgrep Cloud.

### 3. OWASP Dependency-Check
Queries the NIST National Vulnerability Database against every package in `requirements.txt`. Pipeline fails if any dependency scores 9.0 or above on CVSSv3.

### 4. Trivy — Container Scanning
Scans the built Docker image for OS-level CVEs. Configured to only fail on CRITICAL vulnerabilities that have a patch available. Results uploaded to the GitHub Security tab in SARIF format. Python package vulnerabilities are also checked earlier by OWASP Dependency-Check.

### 5. SBOM — Software Bill of Materials
Generates a complete inventory of every component inside the Docker image using Syft in SPDX JSON format. Required by US Executive Order 14028 for software supply chain security.

### 6. Docker Hub Push
Only executes if Gitleaks, Semgrep, OWASP, and Trivy all pass. Pushes two tags: `latest` and the commit SHA for full traceability.

## 🐳 Docker Security Hardening

The Dockerfile follows security best practices:
- `python:3.12-alpine` base image — minimal attack surface
- `pip install --upgrade pip` — ensures latest pip with no known CVEs
- Non-root user — container runs as `appuser`, not root
- `--no-cache-dir` — reduces image layer size

## 🏗️ Infrastructure as Code

Terraform manages all Kubernetes resources:

```bash
cd terraform
terraform init      # download providers
terraform plan      # preview changes
terraform apply     # apply infrastructure
terraform destroy   # tear down everything
```

Resources managed by Terraform:
- Kubernetes Deployment (2 replicas, resource limits, health checks)
- Kubernetes Service (NodePort on 30080)

## 🧪 Test a Pipeline Failure

To see the pipeline catch a real vulnerability, add this to `app/requirements.txt`:

```
Pillow==9.0.0
```

Push it — OWASP will detect CVE-2023-44271 and fail the build. The image will not be pushed to Docker Hub. Remove it and push again to fix it.

## 📦 Artifacts

Each pipeline run produces downloadable reports under Actions → [run] → Artifacts:
- `dependency-check-report` — Full HTML report of all dependency CVEs
- `sbom-report` — SPDX JSON inventory of all image components

## 🔧 Tech Stack

| Layer | Technology |
|-------|------------|
| App | Python 3.12, Flask 3.0, prometheus-flask-exporter |
| Container | Docker, python:3.12-alpine, non-root user |
| Orchestration | Kubernetes (Minikube), kubectl |
| Infrastructure | Terraform, Kubernetes provider |
| CI/CD | GitHub Actions |
| Security | Gitleaks, Semgrep, OWASP Dependency-Check, Trivy, Syft |
| Registry | Docker Hub |
| Monitoring | Prometheus, Grafana, kube-prometheus-stack |

## 📚 References

- [Trivy Documentation](https://aquasecurity.github.io/trivy)
- [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/)
- [Semgrep Rules](https://semgrep.dev/r)
- [Gitleaks](https://github.com/gitleaks/gitleaks)
- [NTIA SBOM Guidance](https://www.ntia.gov/sbom)
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [Terraform Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
