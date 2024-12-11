resource "aws_security_group" "ssh_provisioners" {
  
  name = "iac-provisioner-ssh"
  
  description = "Security Group EC2 Instance"

  ingress {

    description = "Inbound Rule"
    from_port = 22
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {

    description = "Outbound Rule"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    }

}

resource "aws_instance" "iac_instance" {
  
  ami = "ami-088d38b423bff245f"  
  
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ssh_provisioners.id]
  
  key_name = "iac-provisioners"

  tags = {
    Name = "iac-instance"
  }

  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"

    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = file("iac-provisioners.pem")
      host     = self.public_ip
    }
  }

  provisioner "remote-exec" {
    
    inline = ["chmod +x /tmp/script.sh", "/tmp/script.sh"]

    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = file("iac-provisioners.pem")
      host     = self.public_ip
    }
  }
}
