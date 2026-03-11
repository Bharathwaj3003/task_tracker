# Task Tracker Deployment

This repository demonstrates a complete DevOps workflow for deploying a **Task Tracker API** using modern infrastructure and automation practices.

The project includes:

- Application containerization using **Docker**
- Infrastructure provisioning using **Terraform**
- Configuration management using **Ansible**
- CI/CD using **GitHub Actions**
- Monitoring using **Prometheus and Grafana**

---

# Architecture Overview
                +---------------------+
                |      GitHub Repo     |
                |----------------------|
                |  Code                |
                |  Docker              |
                |  Terraform           |
                |  Ansible             |
                |  Pipelines           |
                +----------+-----------+
                           |
                           | GitHub Actions CI/CD
                           v
                +----------------------+
                |   Docker Hub Registry |
                |----------------------|
                | task_tracker images   |
                +----------+-----------+
                           |
                           | docker compose pull
                           v
                +-----------------------------+
                |        AWS EC2 Instance      |
                |-----------------------------|
                | Ubuntu 22.04                |
                |                             |
                |  +-----------------------+  |
                |  |   Task Tracker API    |  |
                |  |   Port 3000 -> 80     |  |
                |  +-----------------------+  |
                |             |               |
                |             v               |
                |  +-----------------------+  |
                |  |      PostgreSQL       |  |
                |  +-----------------------+  |
                |                             |
                |  +-----------------------+  |
                |  |    Node Exporter      |  |
                |  +-----------------------+  |
                |             |               |
                |             v               |
                |  +-----------------------+  |
                |  |      Prometheus       |  |
                |  +-----------------------+  |
                |             |               |
                |             v               |
                |  +-----------------------+  |
                |  |        Grafana        |  |
                |  +-----------------------+  |
                +-----------------------------+


---

# Repository Structure
task-tracker
│
├── code
│ └── Application source code
│
├── docker
│ ├── Dockerfile
│ └── docker-compose.yml
│
├── terraform
│ ├── backend.tf
│ ├── provider.tf
│ ├── main.tf
│ └── outputs.tf
│
├── cloudformation
│ └── terraform-backend.yaml
│
├── ansible
│ ├── install_docker.yml
│ └── inventory.ini
│
├── prometheus
│ └── prometheus.yml
│
├── .github/workflows
│ ├── bootstrap-server.yml
│ ├── build-and-deploy.yml
│ └── rollback.yml
│
└── README.md


---

# Directory Explanation

## code/

Contains the **Task Tracker API application**.

Responsibilities:

- REST API endpoints
- Business logic
- Database interaction

Example endpoints:
POST /tasks
GET /tasks


---

# docker/

Contains containerization configuration.

### Dockerfile

Builds the application container.

Used by CI/CD pipeline to produce container images.

### docker-compose.yml

Defines the runtime stack:
api
postgres
node_exporter
prometheus
grafana

The entire stack can be started using:
docker compose up -d


---

# terraform/

Contains **Infrastructure as Code** used to provision AWS resources.

Terraform provisions:

- EC2 Instance
- Security Group
- Key Pair

### Files

| File | Purpose |
|-----|------|
provider.tf | AWS provider configuration |
backend.tf | Terraform remote state configuration |
main.tf | EC2 infrastructure |
outputs.tf | public IP output |

---

# cloudformation/

Creates backend infrastructure required for **Terraform remote state**.

Resources created:

- S3 bucket (Terraform state storage)

This prevents concurrent Terraform operations.

---

# ansible/

Used for **configuration management** of the EC2 server.

Responsibilities:

- Install Docker
- Install Docker Compose
- Prepare host for container deployment

### install_docker.yml

Installs:
docker
docker compose


### inventory.ini

Defines server inventory.

Example:
[task-tracker-server]
x.x.x.x ansible_user=ubuntu


---

# monitoring/

Contains monitoring configuration.

### prometheus.yml

Defines Prometheus scrape targets.

Prometheus collects metrics from:
node_exporter
task_tracker_api


Metrics include:

- CPU usage
- Memory usage
- Network
- Container metrics

---

# .github/workflows/

Contains **GitHub Actions workflows**.

CI/CD pipeline handles:
Bootstrap Server
Build
Push
Deploy
Rollback


---

## bootstrap-server.yml

Runs Ansible to prepare the server.

Installs:
Docker
Docker Compose


---

## build-and-deploy.yml

Pipeline triggered manually.

Steps:
Build Docker image
Push to DockerHub
Copy docker-compose.yml to server
Update image tag
Deploy containers


---

## rollback.yml

Allows manual rollback to a previous container image.

Steps:
Update image tag
Run docker compose


---

# Infrastructure Setup

## Deploy Terraform Backend

aws cloudformation deploy
--stack-name terraform-backend
--template-file cloudformation/terraform-backend.yaml


---

# Provision Infrastructure

Navigate to terraform directory:
cd terraform

Initialize Terraform:
terraform init

Plan infrastructure:
terraform plan --out task_tracker

Apply infrastructure:
terraform apply


Terraform outputs the **EC2 public IP**.

---

# Monitoring Setup

Monitoring stack includes:

- Prometheus
- Grafana
- Node Exporter

---
## Endpoints

| Service | URL |
|------|------|
API | http://3.109.132.73 |
Prometheus | http://3.109.132.73:9090 |
Node Exporter | http://3.109.132.73:9100/metrics |
Grafana | http://3.109.132.73:3000 |