What You'll Learn: Basic VPC concepts, CIDR blocks, Internet Gateway, Route Tables, and launching an EC2 instance with public access.

## Architecture Diagram

```
┌─────────────────────────────────────────────┐
│           AWS Region (us-east-1)            │
│                                             │
│  ┌───────────────────────────────────────┐  │
│  │     VPC (10.0.0.0/16)                 │  │
│  │                                       │  │
│  │  ┌─────────────────────────────────┐  │  │
│  │  │ Public Subnet (10.0.1.0/24)     │  │  │
│  │  │  Availability Zone: us-east-1a  │  │  │
│  │  │                                 │  │  │
│  │  │  ┌──────────────────┐           │  │  │
│  │  │  │  EC2 Instance    │           │  │  │
│  │  │  │  Public IP       │           │  │  │
│  │  │  └──────────────────┘           │  │  │
│  │  │                                 │  │  │
│  │  └─────────────────────────────────┘  │  │
│  │              │                        │  │
│  │              │ Route Table            │  │
│  │              │ 0.0.0.0/0 → IGW        │  │
│  │              ↓                        │  │
│  │     ┌────────────────┐                │  │
│  │     │ Internet       │                │  │
│  │     │ Gateway (IGW)  │                │  │
│  │     └────────────────┘                │  │
│  │              │                        │  │
│  └──────────────┼───────────────────────-┘  │
│                 │                           │
└─────────────────┼─────────────────────────--┘
                  │
                  ↓
                Internet
```
