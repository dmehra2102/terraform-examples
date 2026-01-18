# Production-Grade AWS ECS Fargate Infrastructure with Terraform

This repository contains a complete, modular Terraform configuration for deploying a high-availability containerized Golang application on AWS ECS Fargate.

## Architecture Overview

### Infrastructure Components

```
                    ┌─────────────────────────────────────────────────────────────────┐
                    │                         AWS Cloud                               │
                    │                                                                 │
                    │  ┌────────────────────────────────────────────────────────────┐ │
                    │  │                    VPC (10.0.0.0/16)                       │ │
                    │  │                                                            │ │
                    │  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │ │
                    │  │  │   AZ-1a      │  │   AZ-1b      │  │   AZ-1c      │      │ │
                    │  │  │              │  │              │  │              │      │ │
                    │  │  │ Public       │  │ Public       │  │ Public       │      │ │
                    │  │  │ Subnet       │  │ Subnet       │  │ Subnet       │      │ │
                    │  │  │ 10.0.1.0/24  │  │ 10.0.2.0/24  │  │ 10.0.3.0/24  │      │ │
                    │  │  │              │  │              │  │              │      │ │
                    │  │  │  ┌────────┐  │  │  ┌────────┐  │  │  ┌────────┐  │      │ │
                    │  │  │  │  NAT   │  │  │  │  NAT   │  │  │  │  NAT   │  │      │ │
                    │  │  │  │Gateway │  │  │  │Gateway │  │  │  │Gateway │  │      │ │
                    │  │  │  └────────┘  │  │  └────────┘  │  │  └────────┘  │      │ │
                    │  │  │              │  │              │  │              │      │ │
                    │  │  │      ┌───────────────────────────────────────┐   │      │ │
                    │  │  │      │   Application Load Balancer (ALB)     │   │      │ │
                    │  │  │      └───────────────────────────────────────┘   │      │ │
                    │  │  │              │  │              │  │              │      │ │
                    │  │  ├──────────────┤  ├──────────────┤  ├──────────────┤      │ │
                    │  │  │              │  │              │  │              │      │ │
                    │  │  │ Private      │  │ Private      │  │ Private      │      │ │
                    │  │  │ Subnet       │  │ Subnet       │  │ Subnet       │      │ │
                    │  │  │ 10.0.11.0/24 │  │ 10.0.12.0/24 │  │ 10.0.13.0/24 │      │ │
                    │  │  │              │  │              │  │              │      │ │
                    │  │  │ ┌──────────┐ │  │ ┌──────────┐ │  │ ┌──────────┐ │      │ │
                    │  │  │ │ECS Task  │ │  │ │ECS Task  │ │  │ │ECS Task  │ │      │ │
                    │  │  │ │ (Fargate)│ │  │ │ (Fargate)│ │  │ │ (Fargate)│ │      │ │
                    │  │  │ └──────────┘ │  │ └──────────┘ │  │ └──────────┘ │      │ │
                    │  │  │              │  │              │  │              │      │ │
                    │  │  └──────────────┘  └──────────────┘  └──────────────┘      │ │
                    │  │                                                            │ │
                    │  └────────────────────────────────────────────────────────────┘ │
                    │                                                                 │
                    │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
                    │  │     ECR      │  │  CloudWatch  │  │  Secrets Mgr │           │
                    │  │  Repository  │  │    Logs      │  │  / Param St. │           │
                    │  └──────────────┘  └──────────────┘  └──────────────┘           │
                    │                                                                 │
                    └─────────────────────────────────────────────────────────────────┘
```

### Key Features

- ✅ **High Availability**: Deployed across 3 Availability Zones
- ✅ **Auto Scaling**: CPU and Memory-based autoscaling (2-10 tasks)
- ✅ **Security**: Least privilege IAM, private subnets, security groups
- ✅ **Observability**: CloudWatch Logs, Container Insights, VPC Flow Logs
- ✅ **Zero-Downtime Deployments**: Circuit breaker, health checks
- ✅ **Cost Optimization**: Fargate Spot capacity providers
- ✅ **Production Ready**: SSL/TLS, logging, monitoring, backups

## Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.6.0
- AWS CLI configured
- ACM Certificate for HTTPS (must be in the same region)
- Docker for building container images
