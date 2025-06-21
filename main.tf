resource "aws_vpc" "pp2_vpc" {
  cidr_block           = "10.110.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "pp2-vpc"
  }
  }

resource "aws_subnet" "pp2_aws_subnet" {
  vpc_id                  = aws_vpc.pp2_vpc.id
  cidr_block              = "10.110.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "pp2-subnet"
  }
  }

resource "aws_internet_gateway" "pp2_igw" {
  vpc_id = aws_vpc.pp2_vpc.id

  tags = {
    Name = "pp2-igw"
  }
  }

resource "aws_route_table" "pp2_public_rt" {
  vpc_id = aws_vpc.pp2_vpc.id

  tags = {
    Name = "pp2-public-rt"
  }
  }

resource "aws_route" "pp2_aws_route" {
  route_table_id         = aws_route_table.pp2_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.pp2_igw.id
  }

resource "aws_route_table_association" "pp2_public_association" {
  subnet_id      = aws_subnet.pp2_aws_subnet.id
  route_table_id = aws_route_table.pp2_public_rt.id
  }


resource "tls_private_key" "pp2_private_key" {
  algorithm = "RSA"
  rsa_bits = 4096
  }

resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = file("~/.ssh/id_rsa.pub")
  }
  
resource "local_file" "ssh_key"{
  filename = "${aws_key_pair.mykeypair.key_name}.pem"
  content = tls_private_key.pp2_private_key.private_key_pem
  directory_permission = 0755
  file_permission = 0600
  }

# Nextcloud Instance Configuration
resource "aws_security_group" "pp2_sg" {
  name        = "pp2_sg"
  description = "pp2 security group"
  vpc_id      = aws_vpc.pp2_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  }

resource "aws_s3_bucket" "pp2_s3_bucket"{
  bucket = "nextcloud-hithesh24r-admin"
  force_destroy = true
}

resource "aws_instance" "pp2_instance" {
  depends_on = [ aws_s3_bucket.pp2_s3_bucket ]
  instance_type          = "t3a.micro"
  ami                    = data.aws_ami.ubuntu_ami.id
  key_name               = aws_key_pair.mykeypair.key_name
  vpc_security_group_ids = [aws_security_group.pp2_sg.id]
  subnet_id              = aws_subnet.pp2_aws_subnet.id
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "pp2-instance"
  }
  }

resource "aws_eip" "pp2_eip" {
  domain     = "vpc"
  instance   = aws_instance.pp2_instance.id
  depends_on = [aws_internet_gateway.pp2_igw]
  }

resource "cloudflare_record" "pp2_record" {
  zone_id = "7e25d20437a0b912569c81ccea68e619"
  name    = "nextcloud"
  value   = aws_eip.pp2_eip.public_ip
  type    = "A"
  ttl     = 300
  }

# Raspberry Pi Instance Configuration
resource "aws_security_group" "rpi_sg" {
  name        = "rpi_sg"
  description = "Raspberry Pi security group"
  vpc_id      = aws_vpc.pp2_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  }

resource "aws_instance" "rpi_instance" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ubuntu_ami.id
  key_name               = aws_key_pair.mykeypair.key_name
  vpc_security_group_ids = [aws_security_group.pp2_sg.id]
  subnet_id              = aws_subnet.pp2_aws_subnet.id
  user_data              = file("rpi_userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "rpi-instance"
  }
  }

resource "aws_ebs_volume" "rpi_volume_1"{
  availability_zone = "ap-south-1a"
  size = 4
  encrypted = false
  }

resource "aws_volume_attachment" "rpi_volume_attach_1"{
  device_name = "/dev/sdf"
  volume_id = aws_ebs_volume.rpi_volume_1.id
  instance_id = aws_instance.rpi_instance.id
  }

resource "aws_ebs_volume" "rpi_volume_2"{
  availability_zone = "ap-south-1a"
  size = 4
  encrypted = false
  }

resource "aws_volume_attachment" "rpi_volume_attach_2"{
  device_name = "/dev/sdg"
  volume_id = aws_ebs_volume.rpi_volume_2.id
  instance_id = aws_instance.rpi_instance.id
  }

resource "aws_ebs_volume" "rpi_volume_3"{
  availability_zone = "ap-south-1a"
  size = 4
  encrypted = false
  }

resource "aws_volume_attachment" "rpi_volume_attach_3"{
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.rpi_volume_3.id
  instance_id = aws_instance.rpi_instance.id
  }

resource "aws_ebs_volume" "rpi_volume_4"{
  availability_zone = "ap-south-1a"
  size = 4
  encrypted = false
  }

resource "aws_volume_attachment" "rpi_volume_attach_4"{
  device_name = "/dev/sdi"
  volume_id = aws_ebs_volume.rpi_volume_4.id
  instance_id = aws_instance.rpi_instance.id
  }

resource "aws_eip" "rpi_eip" {
  domain     = "vpc"
  instance   = aws_instance.rpi_instance.id
  depends_on = [aws_internet_gateway.pp2_igw]
  }

resource "cloudflare_record" "rpi_record" {
  zone_id = "7e25d20437a0b912569c81ccea68e619"
  name    = "rpi"
  value   = aws_eip.rpi_eip.public_ip
  type    = "A"
  ttl     = 300
  }
# End of the code