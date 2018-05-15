#
# Security group resources
#
resource "aws_security_group" "emr_master" {
  vpc_id                 = "${var.vpc_id}"
  revoke_rules_on_delete = true

  tags {
    Name        = "sg${var.name}Master"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "emr_slave" {
  vpc_id                 = "${var.vpc_id}"
  revoke_rules_on_delete = true

  tags {
    Name        = "sg${var.name}Slave"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "service_access" {
  vpc_id                 = "${var.vpc_id}"
  revoke_rules_on_delete = true

  tags {
    Name        = "sg${var.name}ServiceAccess"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "master_allow_all_egress" {
  type            = "egress"
  from_port       = 0
  to_port         = 65535
  protocol        = "all"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.emr_master.id}"
}

resource "aws_security_group_rule" "slave_allow_all_egress" {
  type            = "egress"
  from_port       = 0
  to_port         = 65535
  protocol        = "all"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.emr_slave.id}"
}
