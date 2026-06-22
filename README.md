

# Cross-Region Multi-Account Network Mesh & Centralized Read Cache
This repository contains the production-ready Infrastructure as Code (IaC) blueprint for a highly secure, cross-region, multi-account networking architecture. The design optimizes for a **99.9999% read availability SLA** and sub-millisecond dashboard queries while strictly enforcing regional data residency compliance (GDPR/Data Sovereignty boundaries) and leaving existing regional database systems entirely untouched.

# Architecture Overview
To balance the conflicting constraints of strict data isolation (keeping PII and heavy media assets locked within regional Aurora databases) and ultra-low latency global monitoring, this platform implements a **CQRS (Command Query Responsibility Segregation) pattern handled at the compute layer over a private VPC Peering network.**

 ```
                                  [ PRIVATE VPC PEERING TUNNEL ]
                                                │
 ┌────────────────────────────────────────┐     │     ┌────────────────────────────────────────┐
 │ CENTRAL HUB VPC (e.g., eu-west-1)      │     │     │ REGIONAL SPOKE VPC (e.g., us-east-2)   │
 │                                        │     │     │                                        │
 │  ┌────────────────────────┐            │     │     │  ┌────────────────────────┐            │
 │  │  Central Lambda        │            │     │     │  │  ECS Fargate API       │            │
 │  │  Router/Dashboard      │            │     │     │  └───────────┬────────────┘            │
 │  └───────────┬────────────┘            │     │     │              │ (Primary Write)         │
 │              │ (Direct Private Read)   │     │     │              ▼                         │
 │              ▼                         │◄────┼────►│  ┌────────────────────────┐            │
 │  ┌────────────────────────┐            │     │     │  │  Existing Aurora DB    │            │
 │  │  DynamoDB Cache Table  │            │     │     │  │  (PII / Full Payload)  │            │
 │  └───────────▲────────────┘            │     │     │  └────────────────────────┘            │
 │              │ (Private Routing)       │     │     │              │                         │
 │  ┌───────────┴────────────┐            │     │     │              │ (Stripped Metadata Async│
 │  │ VPC Gateway Endpoint   │◄───────────┼─────┼─────┴──────────────┘  HTTPS Proxy Write)     │
 │  └────────────────────────┘            │     │
 └────────────────────────────────────────┘     │

```


# Core Architecture Highlights:

**The Synchronous Write Path:** Ingress traffic containing full PII datasets is routed directly to the target Regional Spoke. The local ECS Fargate task commits the full payload to the existing local Aurora PostgreSQL database, satisfying all data residency guidelines.
**The Asynchronous Cache Proxy (VPC Peering):** Immediately following a successful database commit, the Fargate task strips all PII elements from memory. It compiles a lightweight, non-PII metadata payload (e.g., Timestamp, EventID, Hazard Type) and sends an asynchronous HTTPS `POST` request up the private **VPC Peering connection**.
**The Central Hub Ingestion:** The request is captured privately by the Lambda in the Hub VPC, which writes the metadata into a centralized **Amazon DynamoDB** table via a secure **VPC Gateway Endpoint**.
**The High-Speed Read Path:** Internal operations engineers querying the dashboard read exclusively from the centralized DynamoDB table. This guarantees sub-millisecond query responses and isolates the transactional regional databases from read-heavy traffic spikes, preventing connection-pool exhaustion.

# Key Architectural Decisions & Trade-offs

# 1. Why Application-Level Proxy Over EventBridge/others?

While an event-driven architecture using AWS EventBridge is clean, it introduces significant infrastructure sprawl (regional buses, cross-account IAM permissions, dead-letter queues, and complex cloud-to-cloud distributed tracing). By executing the dual-write via the compute layer over existing VPC Peering, we maintain a **minimalist infrastructure footprint** and handle retry configurations directly inside application code where network exceptions are caught and surfaced instantly.

# 2. Why VPC Peering Proxy Over DynamoDB Global Tables?

DynamoDB Global Tables are effective for multi-region active-active setups but carry premium replicated write costs (rWCUs) and storage multipliers across multiple environments. More importantly, using Global Tables would bypass the required VPC Peering infrastructure evaluated in this brief. Using the VPC Peering Proxy architecture forces all operational data flow through the secure network tunnels, validating the network design constraints while optimizing long-term FinOps costs.

# Directory Structure
This codebase adopts a modular, DRY (Don't Repeat Yourself) layout, separating reusable factory definitions from live operational states.

```text
.
├── modules/
│   ├── networking/             # Generic VPC factory module
│   │   ├── main.tf             # Enforces private subnet isolated logic
│   │   ├── variables.tf        # Enforces type constraints and strict descriptions
│   │   └── outputs.tf          # Surfaced attributes for cross-module mapping
│   └── vpc_peering/            # Cross-account, cross-region peering mesh factory
│       ├── main.tf             # Handshake and bi-directional routing injections
│       ├── variables.tf        # Strict networking boundaries
│       └── outputs.tf          # Connection state mapping metrics
└── env/
    └── prod/                   # Live root deployment tier
        ├── main.tf             # Root module orchestrator 
        ├── providers.tf        # Cross-account AWS role assumption profiles
        ├── central_cache.tf    # NoSQL data-store and VPC Gateway Endpoint locks
        └── variables.tf        # Production variable orchestrator

```

---

# Prerequisites & CI/CD Pipeline Assumptions

Before deploying this architecture, verify the following prerequisites are met:

1. **Terraform CLI:** Version `1.5.x` or higher installed locally or in your deployment runner.
2. **Multi-Account IAM Provisioning:** The execution profile in the Central Hub account must have authorization to call `sts:AssumeRole` targeting the Spoke account's cross-account deployment execution role (e.g., `OrganizationAccountAccessRole`).
3. **CIDR Allocation:** The Central Hub CIDR (`10.0.0.0/16`) and Regional Spoke CIDR (`10.1.0.0/16`) must be non-overlapping.


# Deployment Instructions

# Step 1: Clone the Repository & Configure Authentication

Export your target authentication credentials for the primary Central Hub account:

```bash
export AWS_ACCESS_KEY_ID="<your-input-value>"
export AWS_SECRET_ACCESS_KEY="<your-input-value>"
export AWS_DEFAULT_REGION="<your-input-value>"

```

# Step 2: Initialize Environment Parameters

Navigate to the root environment tier and create a secure `terraform.tfvars` file to supply runtime variable declarations (Note: Do not commit this file to version control):

```bash
cd env/prod/
touch terraform.tfvars

```

Populate the configuration details into `terraform.tfvars`:

```hcl
hub_vpc_name              = "protex-prod-hub-vpc"
hub_vpc_cidr              = "10.0.0.0/16"
hub_private_subnet_cidr   = "10.0.1.0/24"
hub_az                    = "eu-west-1a"
dynamodb_table_name       = "protex-global-metadata-cache"

spoke_account_id          = "123456789012" # Target regional Spoke AWS Account ID
spoke_vpc_name            = "protex-prod-us-spoke-vpc"
spoke_vpc_cidr            = "10.1.0.0/16"
spoke_private_subnet_cidr = "10.1.1.0/24"
spoke_az                  = "us-east-2a"

```

### Step 3: Initialize and Run Infrastructure Verification

Run the initialization sequences to securely pull Downstream providers and mapping blocks:

```bash
terraform init

```

Execute a dry-run plan execution to validate that route table injections, cross-account assumptions, security group configurations, and endpoint bindings evaluate successfully against standard syntax trees:

```bash
terraform plan

```

### Step 4: Infrastructure Provisioning

To deploy the cross-account network mesh and centralized read-cache infrastructure live:

```bash
terraform apply --auto-approve

```

## Security & Isolation Controls

This architecture enforces an uncompromising **Zero-Trust Network Perimeter**:

* **No Internet Intermediaries:** All communications traversing the Hub and Spoke boundaries occur purely over the private AWS backbone infrastructure. Subnets are deployed without Internet Gateways or NAT Gateways, completely mitigating public scanning vectors.
* **Prefix-List Routing Interceptions:** The Central Hub utilizes an AWS Managed Prefix List applied to the VPC Gateway Endpoint. Compute resources writing metadata to the cache table are intercepted natively by the VPC router, driving traffic sideways onto internal endpoints without leaking packets to public routing pathways.
* **Strict Security Group Demarcation:** Ingress traffic rules on security wrappers explicitly restrict access based on exact peered CIDR block notation, preventing cross-tenant access.
