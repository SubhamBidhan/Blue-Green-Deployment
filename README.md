# AWS Blue-Green Deployment with Application Load Balancer

A zero-downtime deployment project on AWS demonstrating **Blue-Green** and **Canary** deployment strategies using EC2, Application Load Balancer (ALB) weighted target groups.

## 📌 Project Overview

This project simulates a real-world production deployment scenario where a live application (Blue environment) is upgraded to a new version (Green environment) **without any downtime**, using ALB's weighted target group routing. It also demonstrates how the same setup can be used for **Canary releases** by splitting traffic between old and new versions.

## 🏗️ Architecture

```
                        Route 53 (Custom Domain)
                                 │
                                 ▼
                  Application Load Balancer (Internet-Facing)
                                 │
                     ┌───────────┴───────────┐
                     │   Weighted Routing     │
                     └───────────┬───────────┘
                 ┌───────────────┴───────────────┐
                 ▼                                ▼
          Blue-TG (Target Group)           Green-TG (Target Group)
          ├── Blue Server-1 (EC2)          ├── Green Server-1 (EC2)
          └── Blue Server-2 (EC2)          └── Green Server-2 (EC2)
          (Villa Agency Template)          (Klassy Cafe Template)
```

## 🛠️ Tech Stack / AWS Services Used

| Category | Service / Tool |
|---|---|
| Compute | EC2 (RedHat Linux AMI) |
| Load Balancing | Application Load Balancer (ALB) |
| Networking | Security Groups, Target Groups |
| DNS | Route 53 |
| Web Server | Apache (httpd) |
| Demo Apps | Static HTML templates (TemplateMo) |

## 🚀 Deployment Steps

### 1. Launch Blue Environment
- Launch 2 EC2 instances (RedHat Linux AMI) — `Blue Server-1`, `Blue Server-2`
- Bootstrap via EC2 user data script: installs Apache, downloads and deploys the "Villa Agency" template, starts `httpd`

### 2. Configure Security Group
Inbound rules:
| Type | Source |
|---|---|
| All traffic | Self (SG reference) |
| HTTP (80) | My IP / Anywhere IPv4 |
| HTTPS (443) | My IP / Anywhere IPv4 |

### 3. Create Target Group — `Blue-TG`
- Health check path: `/index.html`
- Register `Blue Server-1` and `Blue Server-2`

### 4. Create Application Load Balancer
- Scheme: Internet-facing
- Listener forwards to `Blue-TG`
- Verify: ALB DNS name serves the Blue (Villa Agency) site

### 5. Launch Green Environment
- Launch 2 EC2 instances (RedHat Linux AMI) — `Green Server-1`, `Green Server-2`
- Bootstrap via EC2 user data script: installs Apache, downloads and deploys the "Klassy Cafe" template, starts `httpd`

### 6. Create Target Group — `Green-TG`
- Health check path: `/index.html`
- Register `Green Server-1` and `Green Server-2`

### 7. Switch Traffic via ALB Listener Rules
Load Balancer → Listeners and rules → select HTTP rule → Manage rule → Edit rule → Edit listener rule:

- **Blue-Green cutover:** Add `Green-TG`, set weights `Blue-TG = 0%`, `Green-TG = 100%` → full, instant, zero-downtime switch
- **Canary release:** Set weights `Blue-TG = 50%`, `Green-TG = 50%` → gradual traffic shift for testing before full rollout

### 8. Custom Domain Integration (Route 53)
1. Route 53 → Hosted Zones → Create Hosted Zone → add domain name
2. Create Records:
   | Record Name | Type | Alias | Routes to |
   |---|---|---|---|
   | (blank — root domain) | A | Yes | ALB (Application/Classic LB) |
   | `www` | A | Yes | Same ALB |
3. At the domain registrar (GoDaddy) → Domain → DNS → Nameservers → replace with the Route 53 NS records
4. Propagation transfers DNS authority from GoDaddy to Route 53 (can take time)

## ✅ Key Concepts Demonstrated
- **Zero-downtime deployment** using ALB weighted target groups
- **Blue-Green deployment**: instant full cutover between two independent environments
- **Canary deployment**: gradual, risk-managed traffic shifting
- **DNS delegation**: migrating domain authority from a third-party registrar to Route 53

## 📂 Repository Structure (suggested)

```
aws-blue-green-deployment/
├── README.md
├── architecture-diagram.png
├── scripts/
│   ├── blue-server-userdata.sh
│   └── green-server-userdata.sh
├── screenshots/
│   ├── 01-blue-tg-created.png
│   ├── 02-alb-blue-only.png
│   ├── 03-green-tg-created.png
│   ├── 04-listener-rule-weighted.png
│   ├── 05-blue-green-cutover.png
│   ├── 06-canary-50-50.png
│   └── 07-route53-records.png
└── docs/
    └── deployment-notes.md
```

## 📸 What to Include in the Repo
- **README.md** (this file) — overview, architecture, steps
- **User data scripts** — the two `.sh` files, saved as separate files (not just pasted in README)
- **Screenshots** — target groups, listener rule with weights, ALB DNS resolving each environment, Route 53 hosted zone/records
- **Architecture diagram** — a simple image (draw.io / Lucidchart export) showing ALB → Blue-TG/Green-TG → EC2 instances → Route 53
- **`.gitignore`** — to exclude any local/temp files if you add automation scripts later
- Optionally, a short **GIF or note** showing the site switching from Villa Agency → Klassy Cafe when weights change (great for portfolio visibility)

## 🔮 Possible Future Enhancements
- Automate the whole flow with Terraform or CloudFormation
- Add Auto Scaling Groups instead of static EC2 instances
- Add HTTPS listener with ACM certificate
- Add CloudWatch alarms tied to target group health for automated rollback
