# Architecture Documentation

## Overview

This document explains the system architecture of the platform, including runtime components, data flow, and integration with supporting cloud services.

---

## Runtime Architecture

The system follows a microservices-based architecture deployed on Amazon EKS.

### Components

- **Users / Clients**
  - External users interacting with the platform

- **Load Balancer / Ingress**
  - Entry point for incoming traffic

- **API Gateway**
  - Handles routing and request control

- **Kubernetes Cluster (EKS)**
  - Orchestrates containerized services

- **Microservices**
  - Order Service
  - Inventory Service
  - Notification Service

- **Database (RDS)**
  - Persistent storage layer

- **ECR**
  - Stores container images

- **AWS Secrets Manager**
  - Manages sensitive configuration

- **Prometheus & Grafana**
  - Monitoring and visualization

---

## Data Flow

- User requests flow from:
  Users → Load Balancer → API Gateway → Kubernetes Services

- Services interact with:
  - RDS for data storage  
  - Secrets Manager for credentials  
  - Prometheus for metrics  

- Kubernetes pulls container images from ECR  

---

## Design Considerations

- Scalability via Kubernetes and Karpenter  
- Fault isolation using microservices  
- Observability through integrated monitoring  
- Secure secret management using AWS services  