# DevOps/SRE Interview Guide

## Technical Concepts Questions

### 1. CI/CD Pipeline Design

**Question**: Describe how you would design a CI/CD pipeline for a microservices application.

**Answer**:
```
A comprehensive CI/CD pipeline for microservices should include:

1. **Source Control Integration**
   - Git-based workflow with feature branches
   - Pull request reviews and automated testing
   - Semantic versioning for releases

2. **Build Stage**
   - Automated builds triggered by code commits
   - Unit tests execution
   - Static code analysis (SonarQube, CodeClimate)
   - Security scanning (Snyk, OWASP)
   - Docker image building with multi-stage Dockerfiles

3. **Testing Stages**
   - Unit tests (80%+ coverage)
   - Integration tests
   - End-to-end tests
   - Performance tests
   - Security tests

4. **Deployment Strategy**
   - Blue-green or canary deployments
   - Environment promotion (dev → staging → production)
   - Infrastructure as Code (Terraform/Helm)
   - Configuration management

5. **Monitoring & Feedback**
   - Application metrics (Prometheus)
   - Log aggregation (ELK stack)
   - Alerting (PagerDuty/Slack)
   - Performance monitoring
```

### 2. Container Orchestration

**Question**: How do you manage secrets and configuration in Kubernetes?

**Answer**:
```
Best practices for secrets and configuration management:

1. **Secrets Management**
   - Use Kubernetes Secrets for sensitive data
   - External secret managers (AWS Secrets Manager, HashiCorp Vault)
   - Encrypt secrets at rest (etcd encryption)
   - Limit access with RBAC

2. **Configuration Management**
   - ConfigMaps for non-sensitive configuration
   - Environment-specific configurations
   - Helm charts with values files
   - GitOps approach with ArgoCD/Flux

3. **Security Best Practices**
   - Never store secrets in container images
   - Use service accounts with minimal permissions
   - Regular secret rotation
   - Audit access to secrets

Example:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
stringData:
  database-password: "secure-password"
  api-key: "api-key-value"
```

### 3. Infrastructure as Code

**Question**: Explain the difference between imperative and declarative infrastructure management.

**Answer**:
```
**Imperative Approach**:
- Describes HOW to achieve desired state
- Step-by-step instructions
- Examples: Shell scripts, Ansible playbooks with tasks
- More control but harder to maintain

**Declarative Approach**:
- Describes WHAT the desired state should be
- System figures out how to achieve it
- Examples: Terraform, Kubernetes manifests, CloudFormation
- Idempotent and easier to reason about

Example - Imperative:
```bash
aws ec2 create-instance --image-id ami-12345 --instance-type t3.micro
aws ec2 create-security-group --group-name web-sg
aws ec2 authorize-security-group-ingress --group-name web-sg --port 80
```

Example - Declarative (Terraform):
```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345"
  instance_type = "t3.micro"
  security_groups = [aws_security_group.web.name]
}

resource "aws_security_group" "web" {
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### 4. Monitoring and Observability

**Question**: What are the four golden signals of monitoring?

**Answer**:
```
The four golden signals from Google's SRE book:

1. **Latency**
   - Time to serve requests
   - Distinguish between successful and failed requests
   - Track percentiles (50th, 95th, 99th)

2. **Traffic**
   - Demand on your system
   - Requests per second, transactions per second
   - Network I/O, concurrent sessions

3. **Errors**
   - Rate of failed requests
   - HTTP 5xx errors, exceptions, timeouts
   - Both explicit and implicit failures

4. **Saturation**
   - How "full" your service is
   - CPU, memory, disk, network utilization
   - Queue depth, thread pool usage

Example Prometheus queries:
```promql
# Latency (95th percentile)
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Traffic
rate(http_requests_total[5m])

# Errors
rate(http_requests_total{status=~"5.."}[5m])

# Saturation
cpu_usage_percent > 80
```

## Practical Scenarios

### 5. Incident Response

**Question**: A production service is down. Walk me through your incident response process.

**Answer**:
```
**Immediate Response (0-5 minutes)**:
1. Acknowledge the incident
2. Assess severity and impact
3. Gather initial information (metrics, logs, alerts)
4. Start incident timeline documentation

**Investigation (5-30 minutes)**:
1. Check recent deployments/changes
2. Review monitoring dashboards
3. Examine error logs and traces
4. Verify dependent services
5. Check infrastructure status

**Mitigation (varies)**:
1. Implement immediate fixes if known
2. Rollback recent changes if suspected
3. Scale resources if capacity issue
4. Fail over to backup systems
5. Communicate status to stakeholders

**Resolution**:
1. Confirm service restoration
2. Monitor for stability
3. Update stakeholders
4. Schedule post-mortem

**Post-Incident**:
1. Conduct blameless post-mortem
2. Identify root cause
3. Create action items
4. Update runbooks and alerts
5. Implement preventive measures

Example incident timeline:
14:30 - Alert fired: High error rate on payment service
14:32 - Investigation started, checked recent deployments
14:35 - Identified database connection pool exhaustion
14:38 - Increased connection pool size
14:40 - Service restored, monitoring for stability
14:45 - All clear confirmed
```

### 6. Performance Optimization

**Question**: How would you troubleshoot a slow-performing web application?

**Answer**:
```
**Systematic Approach**:

1. **Define the Problem**
   - What is "slow"? Baseline vs current performance
   - Which components? Frontend, backend, database
   - When did it start? Recent changes?

2. **Application Performance Monitoring**
   - Response times by endpoint
   - Database query performance
   - External API call latency
   - Error rates and exceptions

3. **Infrastructure Monitoring**
   - CPU, memory, disk I/O utilization
   - Network latency and throughput
   - Load balancer metrics
   - Container/pod resource usage

4. **Database Analysis**
   - Slow query logs
   - Index usage and optimization
   - Connection pool statistics
   - Lock contention

5. **Code Analysis**
   - Profiling CPU and memory usage
   - N+1 query problems
   - Inefficient algorithms
   - Memory leaks

Tools and techniques:
- APM tools (New Relic, Datadog, AppDynamics)
- Profilers (pprof, async-profiler)
- Database monitoring (pg_stat_statements)
- Load testing (JMeter, k6)
- Distributed tracing (Jaeger, Zipkin)

Example investigation:
```bash
# Check application metrics
curl -s http://app/metrics | grep http_request_duration

# Database performance
SELECT query, mean_time, calls FROM pg_stat_statements ORDER BY mean_time DESC;

# System resources
top -p $(pgrep java)
iostat -x 1

# Network latency
ping database-host
traceroute api-service
```

### 7. Security

**Question**: How do you secure a Kubernetes cluster?

**Answer**:
```
**Multi-layered Security Approach**:

1. **Cluster Security**
   - Enable RBAC (Role-Based Access Control)
   - Use Network Policies for microsegmentation
   - Enable audit logging
   - Secure etcd with encryption at rest

2. **Node Security**
   - Keep nodes updated with security patches
   - Use minimal OS (Container-Optimized OS)
   - Configure CIS benchmarks
   - Restrict SSH access

3. **Pod Security**
   - Pod Security Standards/Policies
   - Run containers as non-root
   - Use read-only root filesystems
   - Limit resources and capabilities

4. **Image Security**
   - Scan images for vulnerabilities
   - Use trusted registries
   - Sign images with digital signatures
   - Keep base images updated

5. **Secret Management**
   - Use external secret managers
   - Encrypt secrets at rest
   - Rotate secrets regularly
   - Limit access with RBAC

6. **Network Security**
   - Network policies for traffic control
   - Service mesh for mTLS
   - Ingress controller with SSL termination
   - VPN or private networks

Example security configurations:
```yaml
# Pod Security Standards
apiVersion: v1
kind: Namespace
metadata:
  name: secure-app
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted

# Network Policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

## System Design Questions

### 8. Scalability

**Question**: Design a monitoring system that can handle 1 million metrics per second.

**Answer**:
```
**Architecture Components**:

1. **Data Ingestion Layer**
   - Kafka for high-throughput data streaming
   - Multiple partitions for parallel processing
   - Producers: Applications, exporters, agents

2. **Storage Layer**
   - Time-series database (InfluxDB, TimescaleDB)
   - Data partitioning by time and metrics
   - Data retention policies
   - Compression for older data

3. **Processing Layer**
   - Stream processing (Kafka Streams, Apache Flink)
   - Real-time aggregations and alerts
   - Data enrichment and filtering

4. **Query Layer**
   - Query federation across multiple stores
   - Caching layer (Redis) for frequent queries
   - Load balancers for query distribution

5. **Visualization**
   - Grafana for dashboards
   - Pre-aggregated metrics for performance
   - Alert manager for notifications

**Scaling Strategies**:
- Horizontal partitioning by metric name/tags
- Read replicas for query scaling
- Data tiering (hot/warm/cold storage)
- Sampling and aggregation for high-cardinality metrics

**Performance Optimizations**:
- Batch writes to reduce I/O
- Compression algorithms (Snappy, LZ4)
- Index optimization for common queries
- Connection pooling and prepared statements

Example configuration:
```yaml
# Kafka topic configuration
retention.ms: 604800000  # 7 days
segment.ms: 86400000     # 1 day
min.insync.replicas: 2
replication.factor: 3

# InfluxDB retention policy
CREATE RETENTION POLICY "one_hour" ON "metrics" DURATION 1h REPLICATION 1 DEFAULT
CREATE RETENTION POLICY "one_day" ON "metrics" DURATION 24h REPLICATION 1
CREATE RETENTION POLICY "one_week" ON "metrics" DURATION 168h REPLICATION 1
```

### 9. Disaster Recovery

**Question**: Design a disaster recovery plan for a multi-region application.

**Answer**:
```
**Disaster Recovery Strategy**:

1. **RTO/RPO Requirements**
   - Recovery Time Objective (RTO): How quickly to restore
   - Recovery Point Objective (RPO): How much data loss is acceptable
   - Business impact analysis

2. **Multi-Region Architecture**
   - Active-Active or Active-Passive setup
   - Database replication across regions
   - DNS failover mechanisms
   - Load balancer configuration

3. **Data Backup Strategy**
   - Automated backups with retention policies
   - Cross-region backup replication
   - Point-in-time recovery capability
   - Backup validation and testing

4. **Infrastructure as Code**
   - Terraform for consistent infrastructure
   - GitOps for configuration management
   - Automated provisioning in DR region

5. **Monitoring and Alerting**
   - Health checks across regions
   - Automated failover triggers
   - Status page for communication

6. **Testing and Validation**
   - Regular DR drills
   - Chaos engineering practices
   - Recovery procedure documentation
   - Team training and runbooks

**Implementation Example**:
```hcl
# Terraform - Multi-region setup
provider "aws" {
  alias  = "primary"
  region = "us-east-1"
}

provider "aws" {
  alias  = "dr"
  region = "us-west-2"
}

# RDS with cross-region backup
resource "aws_db_instance" "primary" {
  provider = aws.primary
  backup_retention_period = 7
  backup_window = "03:00-04:00"
  copy_tags_to_snapshot = true
}

# Route 53 health check and failover
resource "aws_route53_health_check" "primary" {
  fqdn = "app.example.com"
  port = 443
  type = "HTTPS"
  resource_path = "/health"
}
```

## Behavioral Questions

### 10. Problem-Solving

**Question**: Tell me about a time when you had to troubleshoot a complex production issue.

**Answer Structure**:
```
**Situation**: 
Describe the context - what system, what was happening, impact on business

**Task**: 
What was your responsibility in resolving the issue

**Action**: 
Detailed steps you took to diagnose and fix the problem
- Investigation methods
- Tools used
- Communication with team
- Decision-making process

**Result**: 
Outcome and lessons learned
- How quickly resolved
- Prevention measures implemented
- Process improvements
```

### 11. Continuous Learning

**Question**: How do you stay current with DevOps/SRE technologies?

**Answer**:
```
**Learning Strategies**:

1. **Hands-on Practice**
   - Personal projects and labs
   - Contributing to open source
   - Experimenting with new tools

2. **Community Engagement**
   - DevOps meetups and conferences
   - Online communities (Reddit, Stack Overflow)
   - Following industry leaders on Twitter/LinkedIn

3. **Formal Learning**
   - Cloud provider certifications
   - Online courses (Coursera, Udemy, Pluralsight)
   - Books and whitepapers

4. **Professional Development**
   - Internal training and workshops
   - Cross-team collaboration
   - Mentoring and being mentored

5. **Information Sources**
   - Technical blogs and newsletters
   - Podcast listening
   - Documentation and release notes
   - Vendor webinars and demos

**Recent Learning Examples**:
- Implemented GitOps with ArgoCD
- Studied eBPF for observability
- Learned Rust for systems programming
- Explored WebAssembly for edge computing
```

## Hands-on Technical Challenges

### 12. Kubernetes Troubleshooting

**Question**: A pod is stuck in Pending state. How do you troubleshoot this?

**Answer**:
```bash
# Check pod status and events
kubectl describe pod <pod-name> -n <namespace>

# Common issues and solutions:

# 1. Insufficient resources
kubectl get nodes
kubectl describe nodes
kubectl top nodes

# 2. Image pull issues
kubectl get events --sort-by=.metadata.creationTimestamp
# Check image name, registry access, secrets

# 3. Scheduling constraints
kubectl get pod <pod-name> -o yaml | grep -A 10 nodeSelector
kubectl get nodes --show-labels

# 4. PVC mounting issues
kubectl get pvc
kubectl describe pvc <pvc-name>

# 5. Resource quotas
kubectl get resourcequota -n <namespace>
kubectl describe resourcequota -n <namespace>

# 6. Pod security policies
kubectl get psp
kubectl auth can-i use psp/<policy-name> --as=system:serviceaccount:<namespace>:<serviceaccount>
```

### 13. Docker Performance

**Question**: How would you optimize a Docker image that's taking too long to build?

**Answer**:
```dockerfile
# Optimization strategies:

# 1. Use multi-stage builds
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:16-alpine AS production
COPY --from=builder /app/node_modules ./node_modules
COPY . .
CMD ["node", "server.js"]

# 2. Optimize layer caching
# Copy dependency files first (changes less frequently)
COPY package*.json ./
RUN npm install
# Copy source code last (changes frequently)
COPY . .

# 3. Use .dockerignore
# Create .dockerignore file:
node_modules
npm-debug.log
.git
.gitignore
README.md
Dockerfile
.dockerignore

# 4. Minimize base image size
# Instead of: FROM ubuntu:20.04
# Use: FROM node:16-alpine

# 5. Clean up in the same layer
RUN apt-get update && \
    apt-get install -y package && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 6. Use specific versions
FROM node:16.14.2-alpine3.15
```

## Salary and Career Questions

### 14. Compensation Expectations

**Question**: What are your salary expectations?

**Answer Strategy**:
```
Research beforehand:
- Use sites like Glassdoor, Levels.fyi, PayScale
- Consider location, company size, experience level
- Factor in total compensation (base + bonus + equity + benefits)

Example response:
"Based on my research and experience level, I'm looking for a total 
compensation package in the range of $X to $Y. However, I'm open to 
discussing the complete package including benefits, professional 
development opportunities, and growth potential."

Typical ranges (US, 2024):
- Junior DevOps Engineer: $70k - $95k
- Mid-level DevOps Engineer: $95k - $130k
- Senior DevOps Engineer: $130k - $180k
- Staff/Principal: $180k - $250k+
- SRE roles typically 10-20% higher
```

### 15. Career Growth

**Question**: Where do you see yourself in 5 years?

**Answer**:
```
**Growth Path Options**:

1. **Technical Leadership**
   - Staff/Principal Engineer
   - Technical Architect
   - Distinguished Engineer

2. **Management Track**
   - Engineering Manager
   - Director of Engineering
   - VP of Engineering

3. **Specialization**
   - Security Engineer
   - Cloud Architect
   - Platform Engineer

**Development Plan**:
- Continuous learning and certification
- Leadership opportunities and mentoring
- Contributing to open source
- Speaking at conferences
- Building broader business acumen

Example response:
"I see myself growing into a technical leadership role where I can 
influence architecture decisions and mentor other engineers. I'd like 
to deepen my expertise in cloud-native technologies while also 
developing my ability to translate technical solutions into business 
value. Long-term, I'm interested in either a principal engineer role 
or moving into engineering management."
```

## Preparation Tips

### Before the Interview:
1. **Review the Job Description** - Understand required technologies
2. **Research the Company** - Their stack, challenges, culture
3. **Practice Coding** - Bash scripting, Python automation
4. **Prepare Examples** - STAR method for behavioral questions
5. **Set Up Demo Environment** - Be ready for hands-on questions

### During the Interview:
1. **Ask Clarifying Questions** - Don't assume requirements
2. **Think Out Loud** - Explain your reasoning process
3. **Consider Trade-offs** - Discuss pros/cons of solutions
4. **Be Honest** - Say "I don't know" when appropriate
5. **Show Learning Mindset** - How you'd research unknown topics

### Questions to Ask Them:
1. "What does a typical day look like for this role?"
2. "What are the biggest technical challenges facing the team?"
3. "How do you measure success in this position?"
4. "What opportunities are there for professional development?"
5. "What's the on-call rotation like?"
6. "How do you handle technical debt?"
7. "What's the deployment frequency and process?"