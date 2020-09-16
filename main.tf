#################
# Bastion SSH Key
#################
resource "aws_key_pair" "this" {
  key_name   = "${var.hostname}.${var.dns_zone}"
  public_key = var.public_ssh_key
}

########################
# EC2 - Bastion Instance
########################
resource "aws_instance" "this" {
  ami                         = var.ami
  associate_public_ip_address = true
  iam_instance_profile        = var.iam_instance_profile
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.this.key_name
  subnet_id                   = var.subnet_id
  tags                        = merge(var.tags, { Name = "${var.hostname}.${var.dns_zone}" })
  vpc_security_group_ids      = [aws_security_group.this.id]

  root_block_device {
    encrypted   = var.encrypted
    volume_type = var.volume_type
    volume_size = var.volume_size
  }
}

##################
# Route53 DNS Zone
##################
data "aws_route53_zone" "this" {
  count = var.use_external_dns == false ? 1 : 0

  name         = var.dns_zone
  private_zone = false
}

##############################
# Route53 A Record for Bastion
##############################
resource "aws_route53_record" "this" {
  count = var.use_external_dns == false ? 1 : 0

  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = var.hostname
  type    = "A"
  ttl     = "300"
  records = [aws_instance.this.public_ip]
}

##############################
# Security Group - EC2 Bastion
##############################
resource "aws_security_group" "this" {
  description = "Bastion"
  vpc_id      = var.vpc_id
  name        = "bastion-${var.namespace}"
  tags        = merge(var.tags, { Name = "Bastion" })

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = 6
    cidr_blocks = var.allow_cidr
    description = "Allow incoming SSH connections."
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outgoing traffic."
  }
}

#####################################################
# Security Group Rule - Allow Bastion Database Access
#####################################################
resource "aws_security_group_rule" "database_acccess" {
  count = var.database_security_group == null ? 0 : length(var.database_ports)

  type                     = "ingress"
  from_port                = var.database_ports[count.index].port
  to_port                  = var.database_ports[count.index].port
  protocol                 = 6
  source_security_group_id = aws_security_group.this.id
  description              = var.database_ports[count.index].description
  security_group_id        = var.database_security_group
}

##################################################
# Security Group Rule - Allow Bastion Redis Access
##################################################
resource "aws_security_group_rule" "redis_access" {
  count = var.redis_security_group == null ? 0 : 1

  type                     = "ingress"
  from_port                = var.redis_port
  to_port                  = var.redis_port
  protocol                 = 6
  source_security_group_id = aws_security_group.this.id
  description              = "Allow incoming connections from Bastion server."
  security_group_id        = var.redis_security_group
}

##########################################################
# Security Group Rule - Allow Bastion ElasticSearch Access
##########################################################
resource "aws_security_group_rule" "elasticsearch_access" {
  count = var.elasticsearch_security_group == null ? 0 : length(var.elasticsearch_ports)

  type                     = "ingress"
  from_port                = var.elasticsearch_ports[count.index]
  to_port                  = var.elasticsearch_ports[count.index]
  protocol                 = 6
  source_security_group_id = aws_security_group.this.id
  description              = "Allow incoming connections from Bastion server."
  security_group_id        = var.elasticsearch_security_group
}
