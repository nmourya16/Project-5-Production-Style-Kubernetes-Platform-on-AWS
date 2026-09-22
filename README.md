\# Project 5 — Production-Style Kubernetes Platform on AWS



\## Objective



Build and operate a production-style Kubernetes platform on AWS using infrastructure as code, Kubernetes, autoscaling, storage, ingress, RBAC, and GitOps.



The project demonstrates an end-to-end platform workflow:



GitHub → Flux CD → Amazon EKS → Kubernetes Workloads → AWS Services



\---



\## Architecture



```text

&#x20;                        GitHub Repository

&#x20;                               |

&#x20;                               | GitOps

&#x20;                               v

&#x20;                           Flux CD

&#x20;                               |

&#x20;                               v

&#x20;                    +----------------------+

&#x20;                    |     Amazon EKS       |

&#x20;                    |   project5-eks       |

&#x20;                    |                      |

&#x20;                    |  +----------------+  |

&#x20;                    |  | Kubernetes     |  |

&#x20;                    |  | Deployment     |  |

&#x20;                    |  | project5-app   |  |

&#x20;                    |  +-------+--------+  |

&#x20;                    |          |           |

&#x20;                    |      ClusterIP       |

&#x20;                    |          |           |

&#x20;                    +----------|-----------+

&#x20;                               |

&#x20;                               v

&#x20;                      AWS Load Balancer

&#x20;                        / ALB Ingress

&#x20;                               |

&#x20;                               v

&#x20;                            Internet





&#x20;      +----------------+       +----------------+

&#x20;      |   ConfigMap    |       |     Secret     |

&#x20;      +----------------+       +----------------+



&#x20;      +----------------+       +----------------+

&#x20;      | HPA + Metrics  |       |  RBAC / IAM    |

&#x20;      |    Server      |       |                |

&#x20;      +----------------+       +----------------+



&#x20;      +----------------+       +----------------+

&#x20;      |   PVC / EBS    |       |  AWS EBS CSI   |

&#x20;      |    Storage     |       |     Driver     |

&#x20;      +----------------+       +----------------+











AWS Infrastructure

Infrastructure is provisioned using Terraform.

VPC

\- VPC CIDR: 10.50.0.0/16

\- Availability Zones:

&#x20; - eu-north-1a

&#x20; - eu-north-1b

\- 2 public subnets

\- 2 private subnets

\- Internet Gateway

\- Route tables

\- NAT Gateway

Amazon EKS

\- Cluster: project5-eks

\- Kubernetes version: 1.33

\- Node group: project5-ng

\- Instance type: t3.small

\- Minimum nodes: 2

\- Desired nodes: 2

\- Maximum nodes: 3

\- Nodes deployed in private subnets

Terraform modules are used to separate VPC and EKS infrastructure.

Kubernetes Workloads

Namespace

All application resources are deployed into:

project5

Deployment

Application deployment:

project5-app

Configuration:

\- 3 replicas

\- NGINX container

\- CPU request: 100m

\- Memory request: 128Mi

\- CPU limit: 250m

\- Memory limit: 256Mi

Service

A Kubernetes ClusterIP service exposes the application internally:

project5-app-service

ConfigMap and Secret

Application configuration is managed using Kubernetes ConfigMap and Secret resources.

ConfigMap

Contains:

\- APP\_ENV

\- APP\_NAME

\- GITOPS\_MANAGED

Secret

Contains training credentials:

\- APP\_USERNAME

\- APP\_PASSWORD

These values are for project demonstration only.

Horizontal Pod Autoscaling

HPA is configured for the application.

Configuration:

\- Minimum replicas: 3

\- Maximum replicas: 4

\- Target CPU utilization: 50%

Metrics Server provides resource metrics to Kubernetes.

Example verification:

kubectl get hpa -n project5

kubectl top pods -n project5

RBAC

A dedicated ServiceAccount is used by the application:

project5-app-sa

A namespace-scoped Role allows:

\- get pods

\- list pods

\- watch pods

\- get services

\- list services

\- watch services

\- get configmaps

\- list configmaps

\- watch configmaps

The RoleBinding connects the ServiceAccount with the Role.

RBAC was verified using:

kubectl auth can-i get pods \\

&#x20; --as=system:serviceaccount:project5:project5-app-sa \\

&#x20; -n project5

Expected:

yes

A negative permission test was also performed for deleting pods.

Persistent Storage

AWS EBS storage is integrated with Kubernetes using the AWS EBS CSI driver.

Storage configuration

\- StorageClass: gp2

\- Access mode: ReadWriteOnce

\- PVC: project5-app-pvc

\- Requested storage: 1Gi

The PVC was successfully bound to an EBS-backed Persistent Volume.

A persistence test was performed by writing data to the mounted volume and reading it back successfully.

Ingress and AWS Load Balancer

AWS Load Balancer Controller is installed in the EKS cluster.

An internet-facing Application Load Balancer is created through Kubernetes Ingress.

Ingress:

project5-app-ingress

Configuration:

\- Scheme: internet-facing

\- Target type: IP

\- Path: /

The application was successfully accessed through the ALB and returned HTTP 200.

GitOps with Flux CD

Flux CD is used to implement GitOps.

Repository:

Project-5-Production-Style-Kubernetes-Platform-on-AWS

Flux resources:

\- GitRepository: project5-repo

\- Kustomization: project5-app

Flux continuously monitors the Git repository and applies Kubernetes manifests from:

./kubernetes

GitOps validation

A configuration change was made in Git:

GITOPS\_MANAGED: "true"

The change was:

1\. Committed to Git

2\. Pushed to GitHub

3\. Fetched by Flux

4\. Reconciled by Flux

5\. Verified in the Kubernetes ConfigMap

This demonstrated the complete GitOps workflow:

Git commit

&#x20;   ↓

GitHub

&#x20;   ↓

Flux GitRepository

&#x20;   ↓

Flux Kustomization

&#x20;   ↓

Kubernetes ConfigMap

Terraform

Terraform is used to provision the AWS infrastructure.

Main infrastructure includes:

\- VPC

\- Public and private subnets

\- Internet Gateway

\- NAT Gateway

\- Route tables

\- EKS cluster

\- EKS node group

\- IAM roles and policies

Terraform commands:

terraform init

terraform plan

terraform apply

To remove the AWS infrastructure after completing the project:

terraform destroy

Repository Structure

Project-5-Production-Style-Kubernetes-Platform-on-AWS/

│

├── docs/

│

├── flux/

│   ├── gitrepository.yaml

│   └── kustomization.yaml

│

├── kubernetes/

│   ├── app/

│   ├── autoscaling/

│   ├── config/

│   ├── ingress/

│   ├── namespace/

│   ├── rbac/

│   ├── storage/

│   ├── deployment.yaml

│   ├── namespace.yaml

│   └── service.yaml

│

├── screenshots/

│

├── scripts/

│

├── terraform/

│   └── modules/

│       ├── vpc/

│       └── eks/

│

├── .gitignore

└── README.md

Verification

Key verification commands used during the project:

kubectl get nodes

kubectl get pods -n project5

kubectl get svc -n project5

kubectl get ingress -n project5

kubectl get hpa -n project5

kubectl get pvc -n project5

kubectl get storageclass

kubectl top pods -n project5

flux check

flux get sources git -A

flux get kustomizations -A

Skills Demonstrated

This project demonstrates practical experience with:

\- AWS VPC networking

\- Amazon EKS

\- Terraform

\- IAM

\- Kubernetes Deployments

\- Kubernetes Services

\- ConfigMaps

\- Secrets

\- ServiceAccounts

\- RBAC

\- Horizontal Pod Autoscaling

\- Metrics Server

\- Persistent Volumes and PVCs

\- AWS EBS CSI Driver

\- Kubernetes Ingress

\- AWS Load Balancer Controller

\- Application Load Balancer

\- Flux CD

\- GitOps

\- Kubernetes troubleshooting

\- CKA-style operational concepts

Project Status

Completed

The platform was successfully provisioned, configured, tested, and integrated with Flux GitOps.

The AWS infrastructure can be recreated from the Terraform configuration and Kubernetes resources can be restored from the repository.






