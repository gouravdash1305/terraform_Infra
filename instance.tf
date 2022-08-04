# Creating key pair which will be attached the instance.

# resource "aws_key_pair" "my-key" {
#   key_name   = "kali-key"
#   # public_key = file("${path.module}/id_rsa.pub")
# }

# output "keyname" {
#   value = aws_key_pair.my-key.key_name
# }


# Creating Security Groups which will be attached to the instance.

resource "aws_security_group" "allow_tls" {
  name        = "allow TLS"
  description = "Allow TLS inbound traffic"

  # Dynamic block

  dynamic "ingress" {
    for_each = [22, 8000, 9997]
    iterator = port
    content {
      description = "SSH to VPC"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

    }
  }

  # Static block

  #   ingress {
  #     description = "SSH to VPC"
  #     from_port   = 22
  #     to_port     = 22
  #     protocol    = "tcp"
  #     cidr_vlocks = ["0.0.0.0/0"]
  #   }
}


# Creating the EBS volume for instance.

resource "aws_ebs_volume" "gp3_volume" {
  availability_zone = "us-east-1b"
  size              = 8
  type              = "gp3"
  iops              = "3000"
  throughput        = "175"
}


# Attaching the GP3 EBS volume created.

resource "aws_volume_attachment" "volume_attachment" {
  device_name = "/dev/sdc"
  volume_id   = aws_ebs_volume.gp3_volume.id
  instance_id = aws_instance.splunk.id
}


# Creating the AWS Instance.

resource "aws_instance" "splunk" {
  ami             = "ami-0cff7528ff583bf9a"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.my-key.key_name
  security_groups = ["${aws_security_group.allow_tls.name}"]
  tags = {
    Name = "indexer"
  }
}