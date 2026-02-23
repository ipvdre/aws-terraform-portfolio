data "aws_ami" "amazon-linux-2" {
    most_recent = true
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["amazon"]
}

resource "aws_instance" "instance1" {
    ami = data.aws_ami.amazon-linux-2.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.security-group1.id]

    tags = {
        Name = var.instance1_name
    }
}
resource "aws_instance" "instance2" {
    ami = data.aws_ami.amazon-linux-2.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.private.id
    vpc_security_group_ids = [aws_security_group.security-group1.id]
    tags = {
        Name = var.instance2_name
    }
}
