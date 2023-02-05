resource "aws_vpc" "altproject" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    "name" = "altproject"
  }
}

locals {
  subnet_ids = tomap({
    "1" = "${aws_subnet.altproject[0].id}"
    "2" = "${aws_subnet.altproject[1].id}"
    "3" = "${aws_subnet.altproject[0].id}"
  })
}
resource "aws_subnet" "altproject" {
  vpc_id                  = aws_vpc.altproject.id
  cidr_block              = var.subnet_cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone[count.index]
  count                   = length(var.subnet)

  tags = {
    Name = var.subnet[count.index]
  }
}

resource "aws_internet_gateway" "altinternetgateway" {
  vpc_id = aws_vpc.altproject.id

  tags = {
    Name = var.igw
  }
}

resource "aws_route_table" "altroutetable" {
  vpc_id = aws_vpc.altproject.id

  tags = {
    name = "myaltproject"
  }
}

resource "aws_route" "altroute" {
  route_table_id         = aws_route_table.altroutetable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.altinternetgateway.id
}

resource "aws_route_table_association" "altassociation" {
  subnet_id      = aws_subnet.altproject[count.index].id
  route_table_id = aws_route_table.altroutetable.id
  count          = length(aws_subnet.altproject)
}

resource "aws_security_group" "lb-altsecuritygroup" {
  name        = "altsecuritygroup"
  description = "security group for instances"
  vpc_id      = aws_vpc.altproject.id


  dynamic "ingress" {
    for_each = var.security_groups

    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "instancesecurity" {
  vpc_id = aws_vpc.altproject.id

  dynamic "ingress" {
    for_each = var.security_groups

    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.lb-altsecuritygroup.id]
    }
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "myinstance" {
  ami           = data.aws_ami.altinstance.id
  instance_type = var.instances["instance_type"]

  tags = {
    name = "my-instance-${each.key}"
  }

  key_name               = aws_key_pair.mykeypair.id
  vpc_security_group_ids = [aws_security_group.instancesecurity.id]
  for_each               = local.subnet_ids
  subnet_id              = each.value

  root_block_device {
    volume_size = 8
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "local-exec" {
    command = <<-EOT
              echo '[server${each.key}]\n${self.public_ip}' >> ~/host_inventory
    EOT
  }
}

resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ~/host_inventory ~/setup.yml"
  }

  depends_on = [
    aws_instance.myinstance
  ]
}
