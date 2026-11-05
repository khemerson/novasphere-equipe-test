data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "http" "my_ip" {
  url = "https://api.ipify.org"
}

locals {
  # En CI, data.http.my_ip renverrait l'IP du runner : admin_cidr (vars.ADMIN_CIDR) prend le pas.
  my_cidr = var.admin_cidr != "" ? var.admin_cidr : "${chomp(data.http.my_ip.response_body)}/32"
  name    = "novasphere-${var.environment}-${var.owner}"
}

resource "aws_key_pair" "main" {
  key_name   = "${local.name}-key"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

# En equipe, la source est un depot Git epingle sur un tag :
# source = "git::https://github.com/<vous>/terraform-aws-ec2-server.git?ref=v1.1.0"
module "web" {
  source = "../../modules/ec2-server"

  name                   = "${var.environment}-web"
  enable_monitoring_port = true
  ami_id                 = data.aws_ami.debian.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.main.key_name
  admin_cidr             = local.my_cidr
  open_ports             = [80]
}

module "monitoring" {
  source = "../../modules/ec2-server"

  name          = "${var.environment}-monitoring"
  ami_id        = data.aws_ami.debian.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.main.key_name
  admin_cidr    = local.my_cidr
  open_ports    = []
  tags          = { Tier = "ops" }
}

# Refactoring sans destruction : les ressources de S1 changent d'adresse
resource "local_file" "inventory" {
  # false en CI : le fichier n'existe pas sur le runner et serait recree a chaque plan
  count                = var.generate_inventory ? 1 : 0
  filename             = "${path.module}/../../ansible/inventory-${var.environment}.ini"
  file_permission      = "0644"
  directory_permission = "0755"
  content = templatefile("${path.module}/../../templates/inventory.tftpl", {
    web_ip        = module.web.public_ip
    monitoring_ip = module.monitoring.public_ip
  })
}

moved {
  from = local_file.inventory
  to   = local_file.inventory[0]
}
