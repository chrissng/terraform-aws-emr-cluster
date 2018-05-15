data "aws_subnet" "emr_subnet" {
  id = "${var.subnet_id}"
}

#
# EMR resources
#
resource "aws_emr_cluster" "cluster" {
  name           = "${var.name}"
  custom_ami_id  = "${var.custom_ami_id}"
  release_label  = "${var.release_label}"
  applications   = "${var.applications}"
  configurations = "${var.configurations}"

  ec2_attributes {
    key_name                          = "${var.key_name}"
    subnet_id                         = "${var.subnet_id}"
    emr_managed_master_security_group = "${aws_security_group.emr_master.id}"
    emr_managed_slave_security_group  = "${aws_security_group.emr_slave.id}"
    additional_master_security_groups = "${var.additional_master_security_groups}"
    service_access_security_group     = "${data.aws_subnet.emr_subnet.map_public_ip_on_launch ? "" : aws_security_group.service_access.id}"
    instance_profile                  = "${aws_iam_instance_profile.emr_ec2_instance_profile.arn}"
  }

  instance_group = "${var.instance_groups}"

  autoscaling_role = "${aws_iam_role.emr_autoscaling_role.arn}"

  bootstrap_action {
    path = "${var.bootstrap_uri}"
    name = "${var.bootstrap_name}"
    args = "${var.bootstrap_args}"
  }

  log_uri      = "${var.log_uri}"
  service_role = "${aws_iam_role.emr_service_role.arn}"

  tags {
    Name        = "${var.name}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}
