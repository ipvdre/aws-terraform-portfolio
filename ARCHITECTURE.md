# AWS VPC Architecture with Site-to-Site VPN

## Topology Diagram

```
                         ┌──────────────┐
                         │   Internet   │
                         └──────┬───────┘
                                │
                         ┌──────┴───────┐
                         │     IGW      │
                         │  (main-igw)  │
                         └──────┬───────┘
                                │
┌───────────────────────────────┼──────────────────────────────────┐
│  VPC: main-vpc (10.10.0.0/16)│                                   │
│                               │                                   │
│  ┌────────────────────────────┴─────────────────────────────┐    │
│  │  Public Subnet A (10.10.10.0/24) — us-east-1a            │    │
│  │  Route: 0.0.0.0/0 → IGW                                  │    │
│  │  NACL: public-nacl                                        │    │
│  │                                                           │    │
│  │  ┌──────────────────┐    ┌──────────────────┐             │    │
│  │  │   Instance1       │    │  NAT Gateway     │             │    │
│  │  │   (t3.micro)      │    │  (main-nat-gw)   │             │    │
│  │  │   Amazon Linux 2  │    │  EIP: nat-eip    │             │    │
│  │  └──────────────────┘    └────────┬─────────┘             │    │
│  └───────────────────────────────────┼───────────────────────┘    │
│                                      │                            │
│  ┌───────────────────────────────────┴───────────────────────┐    │
│  │  Private Subnet B (10.10.20.0/24) — us-east-1b            │    │
│  │  Route: 0.0.0.0/0 → NAT Gateway                          │    │
│  │  NACL: private-nacl                                       │    │
│  │                                                           │    │
│  │  ┌──────────────────┐                                     │    │
│  │  │   Instance2       │                                     │    │
│  │  │   (t3.micro)      │                                     │    │
│  │  │   Amazon Linux 2  │                                     │    │
│  │  └──────────────────┘                                     │    │
│  └───────────────────────────────────────────────────────────┘    │
│                                                                   │
│                        ┌──────────────────┐                       │
│                        │   VPN Gateway    │                       │
│                        │ (main-vpn-gw)    │                       │
│                        └────────┬─────────┘                       │
└─────────────────────────────────┼─────────────────────────────────┘
                                  │
                        ┌─────────┴────────┐
                        │  VPN Connection  │
                        │  (IPsec, static) │
                        │  Tunnel 1 + 2    │
                        └─────────┬────────┘
                                  │
                        ┌─────────┴────────┐
                        │ Customer Gateway │
                        │ (on-prem router) │
                        └─────────┬────────┘
                                  │
                        ┌─────────┴────────┐
                        │ On-Prem Network  │
                        │ (192.168.1.0/24)  │
                        └──────────────────┘

                    ┌──────────────────────────┐
                    │  HashiCorp Vault          │
                    │  (var.vault_address)      │
                    │  default: https://        │
                    │    127.0.0.1:8200         │
                    │                           │
                    │  secret/vpn-lab:          │
                    │   ├─ onprem_public_ip     │
                    │   └─ onprem_subnet_cidr   │
                    └──────────────────────────┘
                          │
                          │ Terraform reads
                          │ inputs before apply
                          ▼
                    ┌──────────────────────┐
                    │  Terraform            │
                    │  (vault data source)  │
                    └──────────────────────┘

           ┌──────────────────────────────────────┐
           │  Logging & Monitoring                 │
           │                                       │
           │  ┌────────────────────────────────┐   │
           │  │  VPC Flow Logs → CloudWatch    │   │
           │  │  (all traffic, 30-day retain)  │   │
           │  └────────────────────────────────┘   │
           │  ┌────────────────────────────────┐   │
           │  │  CloudTrail → S3 (KMS enc.)    │   │
           │  │  (API audit, file validation)  │   │
           │  └────────────────────────────────┘   │
           │  ┌────────────────────────────────┐   │
           │  │  CloudWatch Alarms             │   │
           │  │  Tunnel 1 + 2 state monitors   │   │
           │  └────────────────────────────────┘   │
           └──────────────────────────────────────┘
```

## Component Breakdown

### VPC (`vpc.tf`)

| Resource | Purpose |
|---|---|
| **VPC** (`10.10.0.0/16`) | The virtual network that contains all resources. DNS support and DNS hostnames are enabled so instances can resolve public DNS names. |
| **Internet Gateway** | Allows resources in the public subnet to communicate directly with the internet. Attached to the VPC. |
| **Elastic IP** | A static public IP address allocated for the NAT gateway. |
| **NAT Gateway** | Sits in the public subnet. Allows instances in the private subnet to initiate outbound internet connections (e.g., package updates) without being directly reachable from the internet. |
| **Public Subnet** (`10.10.10.0/24`, us-east-1a) | Hosts Instance1 and the NAT gateway. Has a route to the internet via the IGW. |
| **Private Subnet** (`10.10.20.0/24`, us-east-1b) | Hosts Instance2. Outbound internet traffic routes through the NAT gateway. Not directly reachable from the internet. |
| **Public Route Table** | Routes `0.0.0.0/0` to the IGW. VPN routes are propagated automatically from the VPN gateway. |
| **Private Route Table** | Routes `0.0.0.0/0` to the NAT gateway. VPN routes are propagated automatically from the VPN gateway. |

### EC2 Instances (`ec2.tf`)

| Resource | Purpose |
|---|---|
| **Instance1** (public subnet) | Amazon Linux 2 instance in the public subnet. Reachable from on-prem via VPN. |
| **Instance2** (private subnet) | Amazon Linux 2 instance in the private subnet. Reachable from on-prem via VPN. Uses NAT gateway for outbound internet. |

Both instances use the `amzn2-ami-hvm` AMI (latest Amazon Linux 2) and are `t3.micro` type.

**Instance hardening:**
- EBS root volumes encrypted at rest (`encrypted = true`)
- IMDSv2 enforced (`http_tokens = "required"`) — blocks legacy IMDSv1 requests, mitigating SSRF-based credential theft from the instance metadata endpoint

### Security (`security.tf`)

#### Network ACLs (Stateless)

NACLs are **stateless** — you must explicitly allow both inbound and outbound traffic, including return traffic on ephemeral ports.

**Public NACL** (applied to public subnet):

| Direction | Rule # | Protocol | Ports | Source/Dest | Purpose |
|---|---|---|---|---|---|
| Inbound | 100 | ICMP | all | On-Prem CIDR | Ping from on-prem |
| Inbound | 110 | TCP | 22 | On-Prem CIDR | SSH from on-prem |
| Inbound | 200 | TCP | 1024-65535 | 0.0.0.0/0 | Return traffic for outbound connections (internet responses require 0.0.0.0/0 — security group provides stateful filtering) |
| Outbound | 100 | ICMP | all | On-Prem CIDR | Ping replies to on-prem |
| Outbound | 110 | TCP | 80 | 0.0.0.0/0 | HTTP to internet |
| Outbound | 120 | TCP | 443 | 0.0.0.0/0 | HTTPS to internet |
| Outbound | 200 | TCP | 1024-65535 | 0.0.0.0/0 | Return traffic for inbound connections (SSH replies) |

**Private NACL** (applied to private subnet):

| Direction | Rule # | Protocol | Ports | Source/Dest | Purpose |
|---|---|---|---|---|---|
| Inbound | 100 | ICMP | all | On-Prem CIDR | Ping from on-prem via VPN |
| Inbound | 110 | TCP | 22 | On-Prem CIDR | SSH from on-prem via VPN |
| Inbound | 200 | TCP | 1024-65535 | VPC CIDR | Return traffic from NAT gateway (scoped to VPC, not 0.0.0.0/0) |
| Inbound | 210 | TCP | 1024-65535 | On-Prem CIDR | Return traffic from on-prem via VPN |
| Outbound | 100 | ICMP | all | On-Prem CIDR | Ping replies to on-prem |
| Outbound | 110 | TCP | 80 | 0.0.0.0/0 | HTTP via NAT gateway |
| Outbound | 120 | TCP | 443 | 0.0.0.0/0 | HTTPS via NAT gateway |
| Outbound | 200 | TCP | 1024-65535 | 0.0.0.0/0 | Return traffic for inbound connections |

#### Security Group (Stateful)

Security groups are **stateful** — return traffic is automatically allowed, so you only need to define the initiating direction.

| Direction | Protocol | Ports | Source/Dest | Purpose |
|---|---|---|---|---|
| Ingress | ICMP | all | On-Prem CIDR | Ping from on-prem |
| Egress | ICMP | all | On-Prem CIDR | Ping to on-prem |
| Ingress | TCP | 22 | On-Prem CIDR | SSH from on-prem |
| Egress | TCP | 80 | 0.0.0.0/0 | HTTP to internet (package updates) |
| Egress | TCP | 443 | 0.0.0.0/0 | HTTPS to internet (package updates) |

### VPN (`vpn.tf`)

| Resource | Purpose |
|---|---|
| **Customer Gateway** | Represents your on-prem router/firewall. Configured with your on-prem public IP and IPsec type. |
| **VPN Gateway** | AWS-side endpoint attached to the VPC. Enables encrypted communication between AWS and your on-prem network. |
| **VPN Connection** | The IPsec tunnel configuration connecting the customer gateway to the VPN gateway. Uses static routing (no BGP). Two tunnels for redundancy. Crypto: AES-256 encryption, SHA2-256 integrity, DH Group 14. |
| **VPN Connection Route** | Tells AWS that traffic destined for your on-prem network CIDR should go through the VPN connection. |
| **Route Propagation** (x2) | Automatically adds VPN routes to both the public and private route tables, so both subnets can reach your on-prem network. |

### Secrets Management (`vault.tf`)

| Resource | Purpose |
|---|---|
| **vault_kv_secret_v2.vpn_secrets** (data source) | Reads sensitive input values from HashiCorp Vault at `secret/vpn-lab` before `terraform apply`. Vault is the source of truth for secrets that exist before Terraform runs. |

**Secrets read from Vault:**

| Key | Description |
|---|---|
| `onprem_public_ip` | Your on-prem router's public IP (used by the Customer Gateway) |
| `onprem_subnet_cidr` | Your on-prem network CIDR block (used in NACLs, SG rules, VPN routes) |

**Design principle:** Vault flows one direction — **Vault → Terraform**. Secrets that exist before Terraform runs (your on-prem IP, network CIDR) belong in Vault. Secrets that Terraform generates during a run (PSKs, tunnel IPs) belong in Terraform state. Writing generated outputs back into Vault doubles state exposure without adding security.

**Authentication:** The Vault provider authenticates using a token passed via `var.vault_token` (stored in `terraform.tfvars`, which is git-ignored). Vault address is parameterized via `var.vault_address` (defaults to `https://127.0.0.1:8200`).

### Logging & Monitoring (`logging.tf`)

| Resource | Purpose |
|---|---|
| **CloudWatch Log Group** | Stores VPC Flow Log data with 30-day retention. |
| **IAM Role + Policy** | Allows the VPC Flow Logs service to write to CloudWatch. Policy scoped to the specific log group ARN. |
| **VPC Flow Log** | Captures all network traffic (ACCEPT + REJECT) across the VPC with 60-second aggregation. |
| **S3 Bucket** (CloudTrail) | Stores CloudTrail logs. KMS-encrypted, versioning enabled, all public access blocked. |
| **CloudTrail** | Logs all API activity in the account. Log file validation enabled to detect tampering. |
| **CloudWatch Alarm — Tunnel 1** | Fires when VPN Tunnel 1 state drops below 1 (DOWN) for two consecutive 5-minute periods. |
| **CloudWatch Alarm — Tunnel 2** | Fires when VPN Tunnel 2 state drops below 1 (DOWN) for two consecutive 5-minute periods. |

### Resource Protection

| Mechanism | Resources | Purpose |
|---|---|---|
| `lifecycle { prevent_destroy = true }` | VPC, VPN Gateway | Prevents accidental `terraform destroy` of critical infrastructure |
| `default_tags` (provider-level) | All AWS resources | Automatically tags every resource with `Project = aws-vpn-lab` and `ManagedBy = terraform` |
| Input validation | IP and CIDR variables | Rejects invalid values at `terraform plan` time before any resources are created |

## Traffic Flows

### On-Prem → Instance1 (public subnet)
```
On-Prem Client → VPN Tunnel → VPN Gateway → Public Route Table → Public Subnet → Instance1
```

### On-Prem → Instance2 (private subnet)
```
On-Prem Client → VPN Tunnel → VPN Gateway → Private Route Table → Private Subnet → Instance2
```

### Instance2 → Internet (e.g., yum update)
```
Instance2 → Private Route Table (0.0.0.0/0 → NAT) → NAT Gateway → Public Subnet → IGW → Internet
```

### Instance1 → Internet
```
Instance1 → Public Route Table (0.0.0.0/0 → IGW) → IGW → Internet
```
