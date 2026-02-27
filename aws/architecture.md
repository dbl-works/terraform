# AWS Architecture

The `aws/stack` is one such module in this repository that serves as an example of how these modules can be combined. It combines the resources one needs for a standard app that uses a postgres DB, redis, and runs a dockerized app in ECS.

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

The environment generates a VPC containing isolated subnets. Incoming internet traffic must pass through the Load Balancer, while private resources like ECS tasks and Databases are placed in Private subnets with zero direct inbound internet access. Outbound traffic from the private subnet routes through an optional NAT Gateway.

```mermaid
graph TD
    classDef aws fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#232F3E;
    classDef external fill:#f6f6f6,stroke:#333,stroke-width:2px;

    Internet((Internet)):::external
    
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

    %% Routing
    Internet -- "Inbound HTTP/S via IGW" --> ALB
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
