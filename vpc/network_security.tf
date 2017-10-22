resource "aws_security_group" "web_dmz_sg" {
  name   = "web_dmz_sg"
  vpc_id = "${aws_vpc.company_vpc.id}"

  // Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "mysql_sg" {
  name   = "mysql_sg"
  vpc_id = "${aws_vpc.company_vpc.id}"

  // Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow ssh from public subnet
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_subnet.public_subnet.cidr_block}"]
  }

  // Allow access to mysql from public subnet
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_subnet.public_subnet.cidr_block}"]
  }

  // Allow ping from public subnet
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${data.aws_subnet.public_subnet.cidr_block}"]
  }
}

resource "aws_network_acl" "public_subnet_acl" {
  vpc_id     = "${aws_vpc.company_vpc.id}"
  subnet_ids = ["${aws_subnet.public_subnet.id}"]

  # Allow HTTP access from anywhere inbound rule
  ingress {
    rule_no    = 100
    from_port  = 80
    to_port    = 80
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  # Allow HTTPS access from anywhere
  ingress {
    rule_no    = 200
    from_port  = 443
    to_port    = 443
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  # Allow SSH access from anywhere
  ingress {
    rule_no    = 300
    from_port  = 22
    to_port    = 22
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  # Allow RDP from anywhere inbound rule
  ingress {
    rule_no    = 400
    from_port  = 3389
    to_port    = 3389
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  # Allow ephemeral ports inbound rule
  # https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_ACLs.html#VPC_ACLs_Ephemeral_Ports
  ingress {
    rule_no    = 500
    from_port  = 1024
    to_port    = 65535
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  # Allow HTTP from anywhere outbound rule
  egress {
    rule_no    = 100
    from_port  = 80
    to_port    = 80
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  # Allow HTTPS from anywhere outbound rule
  egress {
    rule_no    = 200
    from_port  = 443
    to_port    = 443
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  # Allow SSH from anywhere outbound rule
  egress {
    rule_no    = 300
    from_port  = 22
    to_port    = 22
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  # Allow RDP from anywhere outbound rule
  egress {
    rule_no    = 400
    from_port  = 3389
    to_port    = 3389
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  # Allow ephemeral ports outbound rule
  # https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_ACLs.html#VPC_ACLs_Ephemeral_Ports
  egress {
    rule_no    = 500
    from_port  = 1024
    to_port    = 65535
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  tags {
    Name        = "public_subnet_acl"
    Environment = "${var.environment}"
  }
}
