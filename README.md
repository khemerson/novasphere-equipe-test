# novasphere-infra

Depot de depart du module Bac+5 « Terraform et Automatisation du deploiement d'infrastructures dans le cloud ».
Il represente l'infrastructure NovaSphere en etat de fin de module Bac+4 : une instance EC2 Debian
provisionnee par Terraform, configuree par Ansible, avec un inventaire genere automatiquement.

## Prerequis

- Terraform >= 1.14, AWS CLI v2 configure (`aws sts get-caller-identity` repond), ansible-core 2.21 (Python 3.12+), Git
- Une paire de cles SSH : `ssh-keygen -t ed25519 -f ~/.ssh/novasphere -N ""`

## Demarrage

```bash
cd envs/prod                 # ou envs/dev
cp terraform.tfvars.example terraform.tfvars   # renseigner votre trigramme
terraform init
terraform apply
cd ../../ansible
ansible-playbook site.yml    # inventaire de prod (ansible.cfg)
curl http://$(cd ../envs/prod && terraform output -raw web_public_ip)
```

## Fin de journee

```bash
./scripts/stop-evening.sh prod     # le lendemain : ./scripts/start-morning.sh prod
```

En fin de module : `terraform destroy` depuis `envs/dev/` et `envs/prod/`.

## Structure

```
envs/dev/    racine Terraform de dev (backend novasphere/dev/)
envs/prod/   racine Terraform de prod (backend novasphere/prod/)
modules/     module ec2-server
templates/   inventory.tftpl
ansible/     site.yml, ansible.cfg, roles/web (tasks, handlers, templates, defaults)
scripts/     stop-evening.sh, start-morning.sh
```

Les fichiers `ansible/inventory-<env>.ini` ne sont pas versionnes : ils sont produits par `terraform apply`.

