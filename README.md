# Automated Minecraft & Monitoring Stack

An end-to-end Infrastructure as Code (IaC) and automated deployment pipeline for hosting a Minecraft Java server (`itzg/minecraft-server`), automated local backups, Prometheus/Grafana metrics, and an external Gatus + Caddy status page.

## Architecture Overview

- **Containerization (Docker Compose):** Separates workloads into a **Game Host** stack (Minecraft, `mc-backup`, Prometheus, Grafana) and a **Status** stack (Gatus health probes + Caddy automatic HTTPS reverse proxy).
- **Configuration Management (Ansible):** Idempotent roles (`game-host` and `status-vm`) provision Docker, manage host directories, and deploy Compose stacks.
- **Cloud Provisioning (Terraform):** Provides ready-to-apply AWS EC2 infrastructure modules (`terraform/`) for migrating from bare metal to multi-VM cloud hosting.
- **CI/CD (GitHub Actions):** Automatically formats and validates Terraform configurations on every push before executing Ansible deployments over Tailscale.

## Deployment Modes

### Mode A: Bare-Metal Homelab (default)
1. Configure hostname in `ansible/inventory.ini`.
2. Set the server up with `start.sh` or `ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -K`

### Mode B: Multi-VM Cloud Deployment (Terraform)
1. Navigate to `terraform/` and run `terraform init && terraform apply`.
2. Update `ansible/inventory.ini` with the provisioned VM outputs.
3. Run `ansible-playbook -i ansible/inventory.ini ansible/playbook.yml`.


## Operations & Management

Run these commands directly on the host machine to manage the running stacks:

### Access the Minecraft Server Console
Connect via the built-in RCON client (exit with `Ctrl + C` without stopping the server):
```bash
sudo docker exec -i mc-server rcon-cli
```

Run a single server command directly:
```bash
sudo docker exec mc-server rcon-cli op <username>
```

### Stop Services (Preserves World & Config Data)
Gracefully save the Minecraft world and shut down all Compose stacks without deleting persistent volumes or local backups. You can use stop.sh for the same result:
```bash
sudo docker compose -f /opt/minecraft-stack/docker-compose.yml down
sudo docker compose -f /opt/status-stack/docker-compose.yml down
```

### Start Services Manually
Bring both stacks back online without running Ansible:
```bash
sudo docker compose -f /opt/minecraft-stack/docker-compose.yml up -d
sudo docker compose -f /opt/status-stack/docker-compose.yml up -d
```

### Full Cleanup (Destructive)
Stop all containers and **permanently delete** all named Docker volumes (world saves, metrics, and certificates):
```bash
sudo docker compose -f /opt/minecraft-stack/docker-compose.yml down -v
sudo docker compose -f /opt/status-stack/docker-compose.yml down -v
```