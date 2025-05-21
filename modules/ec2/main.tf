resource "tls_private_key" "instance_public_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.instance_public_key.public_key_openssh

  provisioner "local-exec" {
    when    = create
    command = "echo '${tls_private_key.instance_public_key.private_key_pem}' > ./'${self.key_name}'.pem && chmod 400 ./'${self.key_name}'.pem"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ./'${self.key_name}'.pem"
  }

  tags = {
    Name = var.key_name
  }
}

resource "aws_instance" "app_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = templatefile("${path.module}/script.sh", {
    DEPLOY_PRIVATE_KEY = var.deploy_private_key
    DOMAIN             = "${var.name_prefix}.${var.domain_name}"
    POSTHOG_APP_TAG    = "latest" # This release tag is the DockerHub tag
    SENTRY_DSN         = "https://public@sentry.example.com/1"
  })


  tags = {
    Name        = "${var.name_prefix}-app-server"
    Environment = var.environment
    CreateDate  = timestamp()
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_eip" "instance_eip" {
  domain = "vpc"
  tags = {
    Name        = "${var.name_prefix}-eip"
    Environment = var.environment
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.app_server.id
  allocation_id = aws_eip.instance_eip.id
}