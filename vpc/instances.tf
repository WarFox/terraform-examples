data "template_file" "web_server" {
  template = "${file("templates/webserver.sh.tpl")}"
}

data "template_file" "mysql_server" {
  template = "${file("templates/mysql_server.sh.tpl")}"
}

resource "aws_instance" "web_server" {
  instance_type               = "t2.micro"
  ami                         = "ami-acd005d5"
  subnet_id                   = "${aws_subnet.public_subnet.id}"
  associate_public_ip_address = "true"
  key_name                    = "${var.key_pair}"
  vpc_security_group_ids      = ["${aws_security_group.web_dmz_sg.id}"]
  user_data                   = "${data.template_file.web_server.rendered}"

  tags {
    Name        = "web_server"
    Environment = "${var.environment}"
  }
}

resource "aws_instance" "mysql_server" {
  instance_type               = "t2.micro"
  ami                         = "ami-acd005d5"
  subnet_id                   = "${aws_subnet.private_subnet.id}"
  associate_public_ip_address = "false"
  key_name                    = "${var.key_pair}"
  vpc_security_group_ids      = ["${aws_security_group.mysql_sg.id}"]
  user_data                   = "${data.template_file.mysql_server.rendered}"

  tags {
    Name        = "mysql_server"
    Environment = "${var.environment}"
  }
}
