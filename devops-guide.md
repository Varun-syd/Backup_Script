# DevOps/SRE Comprehensive Guide

## Table of Contents
1. [CI/CD Pipelines](#cicd-pipelines)
2. [Infrastructure as Code](#infrastructure-as-code)
3. [Containerization & Orchestration](#containerization--orchestration)
4. [Monitoring & Observability](#monitoring--observability)
5. [Cloud Platforms](#cloud-platforms)
6. [Automation Scripts](#automation-scripts)
7. [Interview Preparation](#interview-preparation)

## CI/CD Pipelines

### GitHub Actions

#### Basic Workflow Structure
```yaml
name: CI/CD Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
      - run: npm ci
      - run: npm test
      - run: npm run build
```

#### Multi-Environment Deployment
```yaml
name: Deploy to Environments
on:
  push:
    branches: [main]

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Staging
        run: |
          echo "Deploying to staging environment"
          # Add your deployment commands here

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Production
        run: |
          echo "Deploying to production environment"
          # Add your production deployment commands here
```

### GitLab CI

#### .gitlab-ci.yml Example
```yaml
stages:
  - build
  - test
  - deploy

variables:
  DOCKER_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

before_script:
  - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY

build:
  stage: build
  script:
    - docker build -t $DOCKER_IMAGE .
    - docker push $DOCKER_IMAGE

test:
  stage: test
  script:
    - docker run --rm $DOCKER_IMAGE npm test

deploy:
  stage: deploy
  script:
    - kubectl set image deployment/app app=$DOCKER_IMAGE
  only:
    - main
```

### Jenkins Pipeline

#### Jenkinsfile Example
```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'your-registry.com'
        IMAGE_NAME = 'your-app'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/your-org/your-repo.git'
            }
        }
        
        stage('Build') {
            steps {
                script {
                    def image = docker.build("${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}")
                }
            }
        }
        
        stage('Test') {
            steps {
                sh 'docker run --rm ${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER} npm test'
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-registry-credentials') {
                        def image = docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}")
                        image.push()
                        image.push('latest')
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        failure {
            emailext (
                subject: "Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Build failed. Check console output at ${env.BUILD_URL}",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
    }
}
```

## Infrastructure as Code

### Terraform

#### AWS Infrastructure Example
```hcl
# Provider configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

# Subnets
resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

# Security Group
resource "aws_security_group" "web" {
  name_prefix = "${var.environment}-web-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-web-sg"
    Environment = var.environment
  }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name        = "${var.environment}-web-server"
    Environment = var.environment
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Outputs
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}
```

### Ansible

#### Playbook Example
```yaml
---
- name: Deploy Web Application
  hosts: web_servers
  become: yes
  vars:
    app_name: "my-web-app"
    app_version: "{{ lookup('env', 'APP_VERSION') | default('latest') }}"
    docker_image: "{{ app_name }}:{{ app_version }}"

  tasks:
    - name: Update package cache
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Install required packages
      apt:
        name:
          - docker.io
          - docker-compose
          - nginx
        state: present

    - name: Start and enable Docker
      systemd:
        name: docker
        state: started
        enabled: yes

    - name: Create application directory
      file:
        path: "/opt/{{ app_name }}"
        state: directory
        owner: root
        group: root
        mode: '0755'

    - name: Copy docker-compose file
      template:
        src: docker-compose.yml.j2
        dest: "/opt/{{ app_name }}/docker-compose.yml"
        owner: root
        group: root
        mode: '0644'
      notify: restart application

    - name: Copy nginx configuration
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/sites-available/{{ app_name }}
        owner: root
        group: root
        mode: '0644'
      notify: restart nginx

    - name: Enable nginx site
      file:
        src: /etc/nginx/sites-available/{{ app_name }}
        dest: /etc/nginx/sites-enabled/{{ app_name }}
        state: link
      notify: restart nginx

    - name: Pull Docker image
      docker_image:
        name: "{{ docker_image }}"
        source: pull

    - name: Start application
      docker_compose:
        project_src: "/opt/{{ app_name }}"
        state: present

  handlers:
    - name: restart application
      docker_compose:
        project_src: "/opt/{{ app_name }}"
        restarted: yes

    - name: restart nginx
      systemd:
        name: nginx
        state: restarted
```

## Key DevOps Best Practices

### 1. Version Control Everything
- Infrastructure code
- Configuration files
- Scripts and automation
- Documentation

### 2. Implement Proper Testing
- Unit tests
- Integration tests
- Infrastructure tests
- Security scanning

### 3. Use Immutable Infrastructure
- Container-based deployments
- Infrastructure as Code
- Blue-green deployments

### 4. Monitor Everything
- Application metrics
- Infrastructure metrics
- Logs and traces
- Business metrics

### 5. Automate Security
- Vulnerability scanning
- Compliance checks
- Secret management
- Access controls

## Common Interview Topics

### Technical Concepts
1. **CI/CD Pipeline Design**
2. **Infrastructure as Code**
3. **Container Orchestration**
4. **Monitoring and Alerting**
5. **Incident Response**
6. **Security Best Practices**
7. **Cloud Architecture**
8. **Performance Optimization**

### Practical Skills
1. **Troubleshooting Production Issues**
2. **Scaling Applications**
3. **Disaster Recovery**
4. **Cost Optimization**
5. **Team Collaboration**