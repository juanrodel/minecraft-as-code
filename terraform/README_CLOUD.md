# Terraform Cloud Infrastructure (`terraform/`)

This directory contains Infrastructure as Code (IaC) definitions for provisioning a multi-VM cloud deployment of the Minecraft and Status monitoring stack on AWS EC2.

## Purpose in This Repository

- **Active Homelab Mode (Default):** The primary deployment runs on a bare-metal Linux host connected via Tailscale MagicDNS, managed directly by Ansible (`../ansible/`) and Docker Compose (`../docker/`). In this mode, GitHub Actions runs `terraform fmt -check` and `terraform validate` on every push to ensure the cloud infrastructure code remains valid and free of syntax or configuration drift.
- **Cloud Migration Mode (Optional):** If you want to spin up dedicated cloud virtual machines instead of using bare metal, these Terraform files dynamically fetch the latest official Canonical Ubuntu 26.04 LTS AMI and provision two isolated EC2 instances (`game_host` and `status_vm`) along with the required security groups and SSH key pairs.

## Resources Provisioned

- **`data.aws_ami.ubuntu_26_04`**: Dynamically resolves the latest official Canonical Ubuntu 26.04 LTS image in your target region.
- **`aws_instance.game_host`**: Runs the `itzg/minecraft-server` container, `mc-backup`, Prometheus, and Grafana.
- **`aws_instance.status_vm`**: Runs Gatus health probes and Caddy automatic HTTPS reverse proxy.
- **`aws_security_group.mc_sg`**: Opens TCP port `25565` for Minecraft Java clients and port `22` for Ansible SSH provisioning.
- **`aws_key_pair.deployer`**: Registers your public SSH key for passwordless Ansible access.

## How to Deploy to AWS

1. **Configure AWS Credentials:**
   Export your AWS access keys or configure a profile via the AWS CLI (`aws configure`).

2. **Initialize Terraform:**
   ```bash
   cd terraform
   terraform init