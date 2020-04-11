resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags = {
    Name   = "${var.vpc_tag}"
    Region = "${var.region}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name   = "${var.igw_tag}"
    Region = "${var.region}"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = "${length(var.public_subnet)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  availability_zone       = "${element(var.public_availability_zone,count.index)}"
  cidr_block              = "${element(var.public_subnet,count.index)}"
  map_public_ip_on_launch = true

  tags = {
    Name   = "${element(var.public_subnet_tag,count.index)}"
    Region = "${var.region}"
  }
}

resource "aws_subnet" "external_subnet" {
  count             = "${length(var.external_subnet)}"
  availability_zone = "${element(var.external_availability_zone,count.index)}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(var.external_subnet,count.index)}"

  tags = {
    Name   = "${element(var.external_subnet_tag,count.index)}"
    Region = "${var.region}"
  }
}

resource "aws_subnet" "internal_subnet" {
  count             = "${length(var.internal_subnet)}"
  availability_zone = "${element(var.internal_availability_zone,count.index)}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(var.internal_subnet,count.index)}"

  tags = {
    Name   = "${element(var.internal_subnet_tag,count.index)}"
    Region = "${var.region}"
  }
}



resource "aws_route_table" "Public_RT" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name   = "${var.public_rt_name}"
    Region = "${var.region}"
  }
}

resource "aws_route_table_association" "Public_RT_association" {
  count          = "${length(var.public_subnet)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.Public_RT.id}"
}

resource "aws_route_table" "External_RT" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name   = "${var.external_rt_name}"
    Region = "${var.region}"
  }
}

resource "aws_route_table_association" "External_RT_association" {
  count          = "${length(var.external_subnet)}"
  subnet_id      = "${element(aws_subnet.external_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.External_RT.id}"
}

resource "aws_route_table" "Internal_RT" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name   = "${var.internal_rt_name}"
    Region = "${var.region}"
  }
}

resource "aws_route_table_association" "Internal_RT_association" {
  count          = "${length(var.internal_subnet)}"
  subnet_id      = "${element(aws_subnet.internal_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.Internal_RT.id}"
}


resource "aws_route" "igw" {
  route_table_id         = "${aws_route_table.Public_RT.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

resource "aws_eip" "elasticip" {
vpc   = true
tags = {
  Name = "eip_ue1_s_shared"
  Region = "${var.region}"
}
}

resource "aws_nat_gateway" "natgateway" {
  subnet_id     = "${aws_subnet.public_subnet[0].id}"
  allocation_id =  "${aws_eip.elasticip.id}"
  tags = {
    Name = "nat-ue1-s-pub1"
    Region = "${var.region}"
  }
}

resource "aws_eip" "elasticip1" {
vpc   = true
tags = {
  Name = "eip-ue1-s-nat-shared"
  Region = "${var.region}"
}
}

resource "aws_nat_gateway" "natgateway1" {
  subnet_id     = "${aws_subnet.public_subnet[1].id}"
  allocation_id =  "${aws_eip.elasticip1.id}"
  tags = {
    Name = "nat-ue1-s-pub2"
    Region = "${var.region}"
  }
}

resource "aws_route" "natgatewayroute" {
  route_table_id         = "${aws_route_table.External_RT.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.natgateway.id}"
}