# AWS Architecture

The [`aws/stack`](./stack/README.md) is one such module in this repository that serves as an example of how these modules can be combined. It combines the resources one needs for a standard app that uses a postgres DB, redis, and runs a dockerized app in ECS.

```mermaid
graph TD
    classDef aws fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#232F3E;
    classDef external fill:#f6f6f6,stroke:#333,stroke-width:2px;

    %% External entities
    Users((Users)):::external
    CF[Cloudflare <br/> DNS / CDN]:::external
    
    subgraph AWS_VPC [AWS Region & VPC]
        ALB[ALB <br/> Load Balancer]:::aws
        ECS[ECS Compute<br/>Dockerized App w/ Autoscaling]:::aws
        RDS[(RDS<br/>PostgreSQL)]:::aws
        ElastiCache[(ElastiCache<br/>Redis)]:::aws
        
        SM[Secrets Manager]:::aws
        S3[S3 <br/> Public/Private Storage]:::aws
        KMS[KMS <br/> Encryption Keys]:::aws
        ECR[ECR Container Registry <br/> Image Scanning for Vulnerabilities]:::aws
        CW[CloudWatch <br/> Logs & Metrics]:::aws
    end

    %% Connections
    Users -- "HTTPS" --> CF
    CF -- "HTTPS" --> ALB
    ALB -- "HTTP / HTTPS" --> ECS
    
    ECS -- "PostgreSQL (TCP 5432)" --> RDS
    ECS -- "Redis (TCP 6379)" --> ElastiCache
    
    ECS -. "HTTPS (Pull Image)" .-> ECR
    ECS -. "HTTPS (Read Secrets)" .-> SM
    ECS -. "HTTPS (Read/Write Obj)" .-> S3
    ECS -. "HTTPS (Logs/Metrics)" .-> CW
    
    %% KMS Dependencies
    RDS -. "API / HTTPS" .-> KMS
    S3 -. "API / HTTPS" .-> KMS
    SM -. "API / HTTPS" .-> KMS
    CW -. "API / HTTPS" .-> KMS

    subgraph CICD_Pipeline [CI/CD Pipeline]
        Git[Git <br/> Source Code]:::external
        Pipeline[Generic CI/CD Pipeline]:::external
        Deploy[Terraform Deploy <br/> ecs-deploy/cluster & service]:::aws
    end

    %% Deployment flow
    Git -- "Push" --> Pipeline
    Pipeline -- "Build & Scanner" --> ECR
    Pipeline -- "Trigger Deploy" --> Deploy
    Deploy -- "Update Service" --> ECS
```

## Global Distribution & VPC Peering

The stack infrastructure is multi-data-center ready. By leveraging the `global-accelerator` and `vpc-peering` modules alongside multiple stack deployments, cross-datacenter traffic distribution and geographic failover can be effortlessly achieved.

Have a look at the [multi-stack](./multi-stack/README.md) module for an example implementation of the Global Distribution setup.

```mermaid
graph TD
    classDef aws fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#232F3E;
    classDef external fill:#f6f6f6,stroke:#333,stroke-width:2px;

    Users((Global Users)):::external
    
    GA[AWS Global Accelerator <br/> Anycast IP Distribution]:::aws
    
    subgraph Primary [Primary Region Data Center]
        ALB_P[Application Load Balancer]:::aws
        ECS_P[ECS Stack App]:::aws
        RDS_M[(RDS Master DB)]:::aws
    end

    subgraph Secondary [Secondary / Failover Region Data Center]
        ALB_S[Application Load Balancer]:::aws
        ECS_S[ECS Stack App]:::aws
        RDS_R[(RDS Read Replica)]:::aws
    end

    %% Network Routing
    Users -- "Optimal Edge Routing" --> GA
    GA -- "Cross-Datacenter Traffic Distribution" --> ALB_P
    GA -- "Cross-Datacenter Traffic Distribution" --> ALB_S
    
    ALB_P --> ECS_P
    ALB_S --> ECS_S

    %% Master and Replica
    ECS_P -- "Internal TCP" --> RDS_M
    ECS_S -- "Internal TCP" --> RDS_R

    %% Peering & Replication
    ECS_S -. "VPC Peering" .-> RDS_M
    RDS_M =="Replication"==> RDS_R
```

## IAM Access Control

We utilize role-based access with only the minimum necessary privileges.

```mermaid
graph TD
    classDef aws fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#232F3E;
    classDef external fill:#f6f6f6,stroke:#333,stroke-width:2px;

    DeployRole[Deploy Role <br/> Pipeline Access]:::aws
    ECSRole[ECS Task Role <br/> Service Access]:::aws
    HumanRole[Human/Guest Roles <br/> Scoped Access]:::aws

    Pipeline[Generic CI/CD Pipeline]:::external
    Deploy[Terraform Deploy <br/> ecs-deploy/cluster & service]:::aws
    ECS[ECS Compute<br/>Dockerized App w/ Autoscaling]:::aws
    
    SM[Secrets Manager]:::aws
    S3[S3 <br/> Public/Private Storage]:::aws
    CW[CloudWatch <br/> Logs & Metrics]:::aws

    %% IAM Access flows
    Pipeline -. "Assumes" .-> DeployRole
    DeployRole -. "Has Permission" .-> Deploy
    ECS -. "Assumes" .-> ECSRole
    
    %% Showing ECS Role enforcing least privilege
    ECSRole -. "Permits Access" .-> SM
    ECSRole -. "Permits Access" .-> S3
    ECSRole -. "Permits Access" .-> CW
```

## Network Topology & Security

The environment generates a VPC containing isolated subnets. Incoming internet traffic is filtered by **AWS WAF (Web Application Firewall)** to block malicious requests before they pass through the Load Balancer. Private resources like ECS tasks and Databases are placed in Private subnets with zero direct inbound internet access. Outbound traffic from the private subnet routes through an optional NAT Gateway.

```mermaid
graph TD
    classDef aws fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#232F3E;
    classDef external fill:#f6f6f6,stroke:#333,stroke-width:2px;
    classDef security fill:#DD344C,stroke:#232F3E,stroke-width:2px,color:#fff;

    Internet((Internet)):::external
    
    WAF[AWS WAF <br/> Web Application Firewall]:::security

    subgraph VPC [AWS VPC]
        IGW[Internet Gateway]:::aws
        
        subgraph PublicSubnet [Public Subnet]
            ALB[Application Load Balancer]:::aws
            NAT[NAT Gateway]:::aws
        end
        
        subgraph PrivateSubnet [Private Subnet]
            ECS[ECS Compute Tasks]:::aws
            RDS[(RDS Database)]:::aws
            Redis[(ElastiCache)]:::aws
        end
    end

    %% Security & Routing
    Internet -- "Inbound HTTP/S via IGW" --> WAF
    WAF -- "Traffic Inspected & Allowed" --> ALB
    ALB -- "Forwards to" --> ECS
    
    ECS -. "Outbound Internet via" .-> NAT
    NAT -. "via IGW" .-> Internet
    
    %% Internal Connections
    ECS -- "Internal TCP" --> RDS
    ECS -- "Internal TCP" --> Redis
```

## Monitoring & Alerting Flow

Comprehensive observability is integrated throughout the stack. Components push logs and metrics to CloudWatch, where thresholds and alarms trigger SNS Topics. These topics forward critical alerts via AWS Chatbot or Lambda directly into Slack.

We also integrate `cloudwatch-kinesis` and `cloudwatch-snowflake` to push telemetry data out of CloudWatch and into Snowflake for ultra-fast querying of metrics.

```mermaid
graph LR
    classDef aws fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#232F3E;
    classDef external fill:#f6f6f6,stroke:#333,stroke-width:2px;

    %% Data Sources
    ECS[ECS / Fargate]:::aws
    RDS[(RDS)]:::aws
    ALB[Load Balancers]:::aws

    %% AWS Monitoring
    CW[CloudWatch <br/> Alarms & Logs]:::aws
    SNS[SNS Topic <br/> Alarms/Events]:::aws
    Chatbot[AWS Chatbot / <br/> Lambda]:::aws
    
    %% Analytics
    Kin[Kinesis Data Firehose]:::aws
    SF[(Snowflake <br/> Data Warehouse)]:::external

    %% Slack
    Slack[Slack Channel]:::external

    %% Flow
    ECS -. "Logs & Metrics" .-> CW
    RDS -. "Metrics" .-> CW
    ALB -. "Metrics" .-> CW
    
    CW -- "Triggers on Threshold" --> SNS
    SNS -- "Invokes" --> Chatbot
    Chatbot -- "Posts Message" --> Slack
    
    %% Telemetry Flow
    CW -- "Streams Telemetry" --> Kin
    Kin -- "Loads Data" --> SF
```

## Data & Database Services

We support a variety of data stores depending on the application's consistency, compute, and caching needs.

*   **Amazon Aurora**: For high-performance, auto-scaling relational database workloads (serverless compute & storage).
*   **Amazon RDS (PostgreSQL)**: The standard managed relational database.
*   **Amazon ElastiCache (Redis)**: Fully managed, in-memory caching service for fast data retrieval.
*   **Amazon Redshift**: Highly scalable data warehouse optimized for analytics.

```mermaid
graph TD
    classDef aws fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#232F3E;
    classDef data fill:#3B48CC,stroke:#232F3E,stroke-width:2px,color:#fff;
    classDef cache fill:#C92519,stroke:#232F3E,stroke-width:2px,color:#fff;
    
    App[ECS Applications <br/> / API Services]:::aws

    subgraph Relational_Databases [Relational Databases]
        Aurora[(Aurora Serverless <br/> Auto-scaling Compute)]:::data
        RDS[(RDS PostgreSQL <br/> Standard Managed DB)]:::data
    end

    subgraph Caching [In-Memory Caching]
        Redis[(ElastiCache Redis <br/> Key-Value Store)]:::cache
    end

    subgraph Analytics [Data Warehousing]
        Redshift[(Redshift <br/> Analytics Cluster)]:::data
    end

    %% Application Access
    App -- "SQL/TCP" --> Aurora
    App -- "SQL/TCP" --> RDS
    App -- "Redis Protocol" --> Redis

    %% Analytics flows
    RDS -. "Replication/ETL" .-> Redshift
    Aurora -. "Replication/ETL" .-> Redshift
```
