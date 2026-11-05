#!/bin/bash
# Recopie les identifiants de session du lab dans les secrets du depot (a chaque Start Lab).
set -euo pipefail
aws sts get-caller-identity --query Arn --output text   # echoue si les identifiants locaux sont perimes
for k in aws_access_key_id aws_secret_access_key aws_session_token; do
  aws configure get "$k" | gh secret set "$(echo "$k" | tr a-z A-Z)"
done
echo "trois secrets AWS mis a jour"
