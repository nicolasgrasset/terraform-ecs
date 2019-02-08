# network.tf

variable "az_count" {
  description = "Number of AZs to cover in a given region"
}

variable "aws_vpc_id" {
  description = "VPC ID"
}

variable "aws_vpc_cidr_block" {
  description = "VPC CIDR Block"
}

variable "aws_vpc_main_route_table_id" {
  description = "VPC Main Route Table ID"
}

# Fetch AZs in the current region
data "aws_availability_zones" "available" {}

# Create var.az_count private subnets, each in a different AZ
resource "aws_subnet" "private" {
  count             = "${var.az_count}"
  cidr_block        = "${cidrsubnet(var.aws_vpc_cidr_block, 8, 128 + count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id            = "${var.aws_vpc_id}"
}

# Create var.az_count public subnets, each in a different AZ
resource "aws_subnet" "public" {
  count                   = "${var.az_count}"
  cidr_block              = "${cidrsubnet(var.aws_vpc_cidr_block, 8, 128 + var.az_count + count.index)}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id                  = "${var.aws_vpc_id}"
  map_public_ip_on_launch = true
}

#
# Output
#

output "aws_subnet_id" {
  value = "${aws_subnet.public.*.id}"
}