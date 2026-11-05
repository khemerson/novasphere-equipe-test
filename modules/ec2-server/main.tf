resource "aws_security_group" "this" {
  # name_prefix force le remplacement du SG v1.0.0 (regles inline) par un SG neuf, sans regle inline.
  # Le nom genere est unique : create_before_destroy fonctionne sans InvalidGroup.Duplicate.
  name_prefix = "novasphere-${var.name}-"
  description = "Regles du serveur ${var.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.this.id
  description       = "SSH restreint"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.admin_cidr
}

resource "aws_vpc_security_group_ingress_rule" "public" {
  for_each          = toset([for p in var.open_ports : tostring(p)])
  security_group_id = aws_security_group.this.id
  description       = "Port ${each.value} public"
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "monitoring" {
  count             = var.enable_monitoring_port ? 1 : 0
  security_group_id = aws_security_group.this.id
  description       = "node exporter, administration seulement"
  from_port         = 9100
  to_port           = 9100
  ip_protocol       = "tcp"
  cidr_ipv4         = var.admin_cidr
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.this.id]

  metadata_options {
    http_tokens = "required" # IMDSv2, remonte par checkov (CKV_AWS_79)
  }

  tags = merge(var.tags, {
    Name = "novasphere-${var.name}"
    Role = var.name
  })
}
