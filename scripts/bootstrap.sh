#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../terraform"
echo "Running terraform init & apply..."
terraform init
terraform apply -auto-approve

# read outputs
TF_KEY_PATH=$(terraform output -raw private_key_path)
CONTROLLER_IP=$(terraform output -raw controller_public_ip)
MANAGER_IP=$(terraform output -raw manager_public_ip)
WORKER_A_IP=$(terraform output -raw worker_a_public_ip)
WORKER_B_IP=$(terraform output -raw worker_b_public_ip)

echo "Terraform complete. Keys at: $TF_KEY_PATH"
echo "Controller: $CONTROLLER_IP"
echo "Manager: $MANAGER_IP"
echo "Worker A: $WORKER_A_IP"
echo "Worker B: $WORKER_B_IP"

# write ansible inventory
INV_FILE="$(dirname "$0")/../ansible/inventory.ini"
cat > "$INV_FILE" <<EOF
[controller]
controller ansible_host=${CONTROLLER_IP}

[manager]
manager ansible_host=${MANAGER_IP}

[workers]
worker_a ansible_host=${WORKER_A_IP}
worker_b ansible_host=${WORKER_B_IP}
EOF

echo "Inventory written: $INV_FILE"

# copy private key into ansible path (ensure permissions)
cp "$TF_KEY_PATH" "$(dirname "$0")/../terraform/terraform-key.pem"
chmod 400 "$(dirname "$0")/../terraform/terraform-key.pem"

# Run ansible playbooks from repo root (assumes ansible installed locally)
cd "$(dirname "$0")/../ansible"
ANSIBLE_PRIVATE_KEY="../terraform/terraform-key.pem"

export ANSIBLE_HOST_KEY_CHECKING=False

echo "Running Ansible playbook: 01_install_docker.yml"
ANSIBLE_PRIVATE_KEY_FILE="$ANSIBLE_PRIVATE_KEY" ansible-playbook -i inventory.ini playbooks/01_install_docker.yml --private-key "$ANSIBLE_PRIVATE_KEY"

echo "Running Ansible playbook: 02_init_swarm_deploy.yml"
ANSIBLE_PRIVATE_KEY_FILE="$ANSIBLE_PRIVATE_KEY" ansible-playbook -i inventory.ini playbooks/02_init_swarm_deploy.yml --private-key "$ANSIBLE_PRIVATE_KEY"

echo "Bootstrap complete. Visit the manager IP: http://${MANAGER_IP}"
