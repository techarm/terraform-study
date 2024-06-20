data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_config.cidr_block
  tags = {
    Name = var.vpc_config.name
  }
}

resource "aws_subnet" "this" {
  for_each          = var.subnet_config
  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr_block

  tags = {
    Name = each.key
  }

  lifecycle {
    precondition {
      condition = contains(data.aws_availability_zones.available.names, each.value.az)
      # error_message = "Invalid availability zone: ${each.value.az}\nValid zones are ${join(", ", data.aws_availability_zones.available.names)}"
      error_message = <<-EOT
      The AZ "${each.value.az}" provided for the subnet "${each.key}" is invalid.

      The applied AWS region "${data.aws_availability_zones.available.id}" supports the following AZs:
      [${join(", ", data.aws_availability_zones.available.names)}]
      EOT
    }
  }
}
