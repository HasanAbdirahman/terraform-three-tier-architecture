# Terraform Three-Tier Architecture Setup

This repository contains a Terraform configuration for deploying a **three-tier architecture** on AWS. The three-tier architecture separates the system into three layers:

1. **Web Tier (Frontend)** - The public-facing layer of the application, usually consisting of a load balancer and web servers.
2. **Application Tier (Middle Tier)** - The backend layer where the business logic resides, often involving API servers, application services, etc.
3. **Database Tier (Backend)** - The data storage layer, consisting of databases like RDS or NoSQL databases.

## Architecture Overview

This Terraform configuration automates the setup of the following components in a three-tier architecture:

### 1. **VPC (Virtual Private Cloud)**

- A custom VPC is created with CIDR block `10.0.0.0/16`.
- It includes both **public subnets** (for the web tier) and **private subnets** (for the application and database tiers).

### 2. **Public Subnet (Web Tier)**

- **Elastic Load Balancer (ELB)**: An **Application Load Balancer** (ALB) is deployed to distribute incoming traffic across web servers.
- The **public subnets** allow for internet-facing resources like the ALB to interact with clients.

### 3. **Private Subnet (Application Tier)**

- The **application tier** typically includes API servers, application logic, and other backend components.
- The **private subnets** are used to host these resources for enhanced security.
- These subnets do not have direct access to the internet but can interact with the public subnets through routing.

### 4. **Database Tier**

- An **RDS instance** (Relational Database Service) is deployed in the private subnet to handle all database operations.
- CloudWatch logs are enabled for monitoring the RDS instance, providing visibility into database performance.

### 5. **Security Groups and IAM Roles**

- **Security Groups**: Different security groups are configured for the **web**, **application**, and **database** layers to control inbound and outbound traffic.
- **IAM Role for RDS**: An IAM role is created to allow the RDS instance to push logs to CloudWatch.

## Features

- **VPC and Subnets**: A custom VPC with public and private subnets for different tiers (web, application, and database).
- **Load Balancer**: An **Application Load Balancer** (ALB) to distribute traffic to the web tier (frontend).
- **RDS Database**: A PostgreSQL database running in a private subnet.
- **CloudWatch Monitoring**: RDS logs are exported to **CloudWatch** for performance and health monitoring.
- **Security**: Security groups and IAM roles are set up to control traffic and permissions.

## Architecture Diagram

Here’s a high-level diagram of the architecture:

+---------------------------------------------+ | Internet | | | | | +--------------------+ | | | Application Load | | | | Balancer | | | +--------------------+ | | | | | +---------------------+ | | | Web Tier (EC2) | | | | (Public Subnets) | | | +---------------------+ | | | | | +---------------------+ | | | Application Servers | | | | (Private Subnets) | | | +---------------------+ | | | | | +------------------------+ | | | Database (RDS) | | | | (Private Subnets) | | | +------------------------+ | +---------------------------------------------+

### Key Components:

- **Public Subnet**: Contains the **Application Load Balancer** (ALB) that routes traffic to the web servers (EC2 instances).
- **Private Subnet**: Houses **Application Servers** (EC2 instances) that run the business logic.
- **Database Tier**: The **RDS PostgreSQL** instance located in the private subnet for storing and managing data.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed.
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate AWS credentials.
- An AWS account with the necessary permissions to create VPCs, subnets, security groups, RDS instances, IAM roles, and more.

## Setup Instructions

### 1. Clone the Repository

Clone the repository to your local machine:

```bash
git clone https://github.com/hasan-abdirahman/terraform-three-tier-architecture.git
cd terraform-three-tier-architecture

```
