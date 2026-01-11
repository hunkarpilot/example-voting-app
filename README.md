# Example Voting App on AWS EKS

This project demonstrates a cloud-native deployment of the Example Voting App on AWS using Terraform and Kubernetes (EKS).

## Architecture Overview

The application is deployed on an Amazon EKS cluster in the `eu-west-2` region.

- **Infrastructure as Code:** Terraform is used to provision the VPC, EKS Cluster, and ECR repositories.
- **Container Registry:** AWS ECR stores the Docker images for the Vote, Result, and Worker applications.
- **Orchestration:** Kubernetes (EKS) manages the application workloads.
- **CI/CD:** GitHub Actions handles the build and deployment process.

![Architecture diagram](architecture.excalidraw.png)

### Components

1.  **Vote App (Python):** Frontend for users to cast votes. Exposed via LoadBalancer.
2.  **Redis:** In-memory queue for incoming votes.
3.  **Worker (.NET):** Background processor that consumes votes from Redis and stores them in PostgreSQL.
4.  **DB (PostgreSQL):** Persistent storage for votes.
5.  **Result App (Node.js):** Frontend to view real-time results. Exposed via LoadBalancer.

## Prerequisites

- AWS Account
- GitHub Repository
- Terraform >= 1.3.2
- AWS CLI
- kubectl

## How to Run the Pipeline

The CI/CD pipeline is managed by GitHub Actions. It triggers automatically on a push to the `main` branch.

### 1. Configure Secrets

In your GitHub repository settings (`Settings > Secrets and variables > Actions`), add the following repository secrets:

- `AWS_ACCESS_KEY_ID`: Your AWS Access Key ID.
- `AWS_SECRET_ACCESS_KEY`: Your AWS Secret Access Key.

*(Note: The pipeline uses the region `eu-west-2` and EKS cluster `talent-904976121950` defined in `deploy.yaml` env vars)*

### 2. Trigger Deployment

Push changes to the `main` branch to trigger the pipeline:

```bash
git add .
git commit -m "Update application"
git push origin main
```

The pipeline will:
1.  Build Docker images for Vote, Result, and Worker apps.
2.  Push images to AWS ECR with the commit SHA as the tag.
3.  Update Kubernetes manifests with the new image tag.
4.  Apply the manifests to the EKS cluster.

## How to Verify Deployment

1.  **Check Pods:**
    ```bash
    kubectl get pods
    ```
    Ensure all pods are in `Running` state.

2.  **Access Applications:**
    Get the LoadBalancer DNS names:
    ```bash
    kubectl get svc vote result
    ```
    - Access the **Vote App** at the `vote` service External-IP (port 80).
    - Access the **Result App** at the `result` service External-IP (port 80).

## Decision Log (Trade-offs)

- **Infrastructure:**
    - **Choice:** Terraform was chosen for IaC as preferred by the requirements.
    - **State Management:** Local backend was used instead of S3/DynamoDB to avoid permission issues and complexity in the restricted sandbox environment. In production, remote backend with locking is mandatory.
    - **Networking:** Used `terraform-aws-modules/vpc` for a production-ready VPC setup with public/private subnets and NAT Gateways.
    - **EKS:** Used a managed Node Group (`t3.xlarge`) for cost-efficiency and simplicity in this scale.

- **CI/CD:**
    - **Tool:** GitHub Actions was chosen for its seamless integration with the code repository.
    - **Authentication:** Used AWS Access Keys for simplicity in the sandbox. In a real-world scenario, OIDC (OpenID Connect) would be preferred for better security (no long-lived credentials).
    - **Deployment Strategy:** `kubectl apply` with dynamic image tag replacement in the pipeline. This ensures the deployed version matches the commit. Manifests in the repo use a placeholder `IMAGE_TAG`.

- **Security:**
    - **Least Privilege:** Terraform uses a specific assumed role (`talent_role`).
    - **Network:** Database and Redis are internal services, not exposed to the public internet. Only Vote and Result apps have LoadBalancers.
    - **Image Scanning:** ECR scan-on-push is enabled to detect vulnerabilities.

## Clean Up

To destroy the infrastructure and avoid costs:

1.  **Delete Kubernetes Resources:**
    ```bash
    kubectl delete -f k8s-specifications/
    ```

2.  **Destroy Terraform Resources:**
    ```bash
    cd terraform
    terraform destroy -auto-approve
    ```
    *(Note: Ensure you have the correct AWS credentials configured)*

## List of AWS Resources Created

- **VPC:** `talent-904976121950` (10.0.0.0/16)
- **Subnets:** 3 Public, 3 Private, 3 Intra
- **NAT Gateway:** 1 (Single NAT Gateway for cost saving)
- **Internet Gateway:** 1
- **EKS Cluster:** `talent-904976121950` (v1.31)
- **EKS Node Group:** `talent-904976121950-ng` (t3.xlarge, desired: 2)
- **ECR Repositories:**
    - `bion-talent-904976121950-voting-app`
    - `bion-talent-904976121950-result-app`
    - `bion-talent-904976121950-worker`
- **IAM Roles (Assumed/Used):** `talent_role` (Sandbox default)