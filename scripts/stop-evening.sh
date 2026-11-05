#!/usr/bin/env bash
# Stoppe l'instance web en fin de journee (pas de facturation compute a l'arret).
# Usage : scripts/stop-evening.sh [prod|dev]   (defaut : prod)
# envs/dev a partir de S4 (ALB + ASG) : pas de script, terraform destroy dans envs/dev.
set -euo pipefail
cd "$(dirname "$0")/../envs/${1:-prod}"
ID=$(terraform output -raw web_instance_id)
aws ec2 stop-instances --instance-ids "$ID" > /dev/null
echo "Instance $ID en cours d'arret. Detruire toute ressource facturee a l'heure (ALB, NAT, ASG)."
