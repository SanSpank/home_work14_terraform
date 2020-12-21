provider "aws" {
  region = "eu-central-1"
}

resource "aws_security_group" "http-group" {
  name = "http-access-group"
  description = "Allow traffic on port 80 (HTTP)"

  tags = {
    Name = "HTTP Inbound Traffic Security Group"
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}
resource "aws_security_group" "ssh-group" {
  name = "ssh-access-group"
  description = "Allow traffic to port 22 (SSH)"

  tags = {
    Name = "SSH Access Security Group"
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}
resource "aws_security_group" "all-outbound-traffic" {
  name = "all-outbound-traffic-group"
  description = "Allow traffic to leave the AWS instance"

  tags = {
    Name = "Outbound Traffic Security Group"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_instance" "example" {
  ami = "ami-0e1ce3e0deb8896d2"
  instance_type = "t2.micro"
  key_name = "sanek"
  vpc_security_group_ids = [
    "${aws_security_group.http-group.id}",
    "${aws_security_group.ssh-group.id}",
    "${aws_security_group.all-outbound-traffic.id}"
  ]
  provisioner "file" {
    source      = "/tmp/skawap/index.html"
    destination = "/tmp/index.html"
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = "${file("/tmp/sanek.pem")}"
      host        = self.public_ip
}
  }
  user_data = <<EOF
#!/bin/bash
sudo apt update
sudo apt install -y docker.io
sudo usermod -aG docker ubuntu
docker run -d -p 80:80 -v /tmp:/usr/share/nginx/html nginx:latest
EOF

}


