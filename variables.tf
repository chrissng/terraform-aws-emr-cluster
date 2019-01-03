variable "project" {
  description = "Name of project this cluster is for"
  default     = "Unknown"
}

variable "environment" {
  description = "Name of environment this cluster is targeting"
  default     = "Unknown"
}

variable "name" {
  description = "Name of EMR cluster"
}

variable "custom_ami_id" {
  description = "Custom AMI ID to base the EMR EC2 instance on"
}

variable "vpc_id" {
  description = "ID of VPC meant to house cluster"
}

variable "release_label" {
  default     = "emr-5.7.0"
  description = "EMR release version to use"
}

variable "applications" {
  description = "List of EMR release applications"
  default     = ["Spark"]
  type        = "list"
}

variable "termination_protection" {
  description = "Switch on/off termination protection"
  default     = "false"
}

variable "configurations" {
  description = "JSON array of EMR application configurations"
}

variable "key_name" {
  description = "EC2 key pair name"
}

variable "subnet_id" {
  description = "Subnet used to house the EMR nodes"
}

variable "instance_groups" {
  description = "List of objects for each desired instance group"

  default = [
    {
      name           = "MasterInstanceGroup"
      instance_role  = "MASTER"
      instance_type  = "m3.xlarge"
      instance_count = 1
    },
    {
      name           = "CoreInstanceGroup"
      instance_role  = "CORE"
      instance_type  = "m3.xlarge"
      instance_count = "1"
      bid_price      = "0.30"
    },
  ]

  type = "list"
}

variable "additional_master_security_groups" {
  description = "Additional master security groups to place the EMR EC2 instances in"
}

variable "bootstrap_name" {
  description = "Name for the bootstrap action"
}

variable "bootstrap_uri" {
  description = "S3 URI for the bootstrap action script"
}

variable "bootstrap_args" {
  description = "List of arguments to the bootstrap action script"
  default     = []
  type        = "list"
}

variable "custom_tags" {
  description = "Custom tags to add to the default EMR tags"
  default     = {}
  type        = "map"
}

variable "log_uri" {
  description = "S3 URI of the EMR log destination, must begin with `s3n://` and end with trailing"
}
