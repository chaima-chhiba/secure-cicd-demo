# 🔐 Secure CI/CD Pipeline

A production-grade DevSecOps pipeline that automatically scans for vulnerabilities on every push.

## 🏗️ Project Structure

\\\
secure-cicd-demo/
├── app/
│   ├── app.py              # Flask application
│   └── requirements.txt    # Python dependencies
├── Dockerfile              # Container definition
├── .github/
│   └── workflows/
│       └── security-scan.yml  # CI/CD pipeline
└── README.md
\\\

## 🛡️ Security Pipeline

Every push triggers 5 automated security jobs:

\\\
Gitleaks (secrets)
    ├── Semgrep SAST (code scan)
    ├── OWASP Dependency-Check (dependencies)
    └── Trivy (docker image scan)
              └── SBOM Generation
\\\

| Tool | What it checks | Fails pipeline if |
|------|---------------|-------------------|
| **Gitleaks** | Secrets & API keys in code/git history | Any secret is found |
| **Semgrep** | Python code vulnerabilities (SAST) | High severity code issue found |
| **OWASP Dependency-Check** | Known CVEs in Python packages | CVSSv3 score ≥ 9.0 |
| **Trivy** | Docker image vulnerabilities | CRITICAL CVE with a fix available |
| **Syft SBOM** | Generates software bill of materials | Never fails — always produces report |

## 🚀 Run Locally

**Prerequisites:** Docker, Python 3.12+, Git

\\\ash
# Clone the repo
git clone https://github.com/chaima-chhiba/secure-cicd-demo.git
cd secure-cicd-demo

# Build and run with Docker
docker build -t secure-cicd-demo .
docker run -p 5000:5000 secure-cicd-demo
\\\

Visit \http://localhost:5000\ — you should see:
\\\json
{"message": "Secure CI/CD Demo", "status": "ok"}
\\\

## 🔬 How the Pipeline Works

### 1. Gitleaks — Secrets Detection
Scans the entire git history for accidentally committed credentials, API keys, or tokens. Uses \etch-depth: 0\ to check every commit, not just the latest.

### 2. Semgrep — SAST
Static analysis of Python source code. Uses the \p/python\ ruleset to detect insecure patterns like SQL injection, unsafe deserialization, and hardcoded credentials.

### 3. OWASP Dependency-Check
Queries the NIST National Vulnerability Database (NVD) against every package in \equirements.txt\. Pipeline fails if any dependency has a CVSSv3 score of 9.0 or above.

### 4. Trivy — Container Scanning
Scans the built Docker image for OS-level and package-level CVEs. Only fails on CRITICAL vulnerabilities that have a patch available (\ignore-unfixed: true\). Results are uploaded to the GitHub Security tab in SARIF format.

### 5. SBOM — Software Bill of Materials
Generates a complete inventory of every component inside the Docker image using Syft, output as \spdx-json\. Required by US Executive Order 14028 for software supply chain security.

## 📊 Artifacts

Each pipeline run produces downloadable reports:
- \dependency-check-report\ — Full HTML report of all dependency CVEs
- \sbom-report\ — SPDX JSON inventory of all image components

Find them under **Actions → [run] → Artifacts**.

## 🧪 Test a Pipeline Failure

To see the pipeline catch a real vulnerability, add this to \pp/requirements.txt\:

\\\
Pillow==9.0.0
\\\

Push it — OWASP will detect CVE-2023-44271 and fail the build. Then remove it and push again to fix it.

## 🔧 Tech Stack

- **App:** Python 3.12, Flask 3.0
- **Container:** Docker (python:3.12-slim, non-root user)
- **CI/CD:** GitHub Actions
- **Security:** Gitleaks, Semgrep, OWASP Dependency-Check, Trivy, Syft

## 📚 References

- [Trivy Documentation](https://aquasecurity.github.io/trivy)
- [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/)
- [Semgrep Rules](https://semgrep.dev/r)
- [Gitleaks](https://github.com/gitleaks/gitleaks)
- [NTIA SBOM Guidance](https://www.ntia.gov/sbom)
