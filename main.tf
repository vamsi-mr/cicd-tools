resource "aws_instance" "jenkins" {
  ami                    = local.ami_id
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = "subnet-08c3a3ba63ceab095"

# need more for terraform
root_block_device {
    volume_size = 50
    volume_type = "gp3" # or "gp2", depending on your preference
}

user_data = file("jenkins-node.sh")

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-jenkins"
    }
  )
}

resource "aws_instance" "jenkins-agent" {
  ami                    = local.ami_id
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = "subnet-08c3a3ba63ceab095"

# need more for terraform
root_block_device {
    volume_size = 50
    volume_type = "gp3" # or "gp2", depending on your preference
}

user_data = file("jenkins-agent.sh")

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-jenkins-agent"
    }
  )
}

resource "aws_security_group" "main" {
  name = "${var.project}-${var.environment}-jenkins"
  description = "created to attach to jenkins and its agents"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"] 
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    local.common_tags, 
    {
      Name = "${var.project}-${var.environment}-jenkins"
    }
  )
}


resource "aws_route53_record" "jenkins" {
  zone_id = var.zone_id
  name = "jenkins.${var.zone_name}"
  type = "A"
  ttl = "1"
  records = [aws_instance.jenkins.public_ip]
  allow_overwrite = true
}

resource "aws_route53_record" "jenkins-agent" {
  zone_id = var.zone_id
  name = "jenkins-agent.${var.zone_name}"
  type = "A"
  ttl = "1"
  records = [aws_instance.jenkins-agent.private_ip]
  allow_overwrite = true
}