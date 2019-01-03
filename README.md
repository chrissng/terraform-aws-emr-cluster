# terraform-aws-emr-cluster

A Terraform module to create an Amazon Web Services (AWS) Elastic MapReduce (EMR) cluster.

_Forked from <https://github.com/azavea/terraform-aws-emr-cluster> to support additional EMR
features. See [CHANGELOG](https://github.com/chrissng/terraform-aws-emr-cluster/releases)_

## Usage

```hcl
data "template_file" "emr_configurations" {
  template = "${file("configurations/default.json")}"
}

module "emr" {
  source = "github.com/chrissng/terraform-aws-emr-cluster?ref=0.3-emr5"

  name          = "DataprocCluster"
  vpc_id        = "vpc-20f74844"
  custom_ami_id = "${module.emr.default_ami_id}"
  release_label = "emr-5.9.0"

  applications = [
    "Hadoop",
    "Ganglia",
    "Spark",
    "Zeppelin",
  ]

  configurations = "${data.template_file.emr_configurations.rendered}"
  key_name       = "hector"
  subnet_id      = "subnet-e3sdf343"

  instance_groups = [
    {
      name           = "MasterInstanceGroup"
      instance_role  = "MASTER"
      instance_type  = "m3.xlarge"
      instance_count = "1"
    },
    {
      name           = "CoreInstanceGroup"
      instance_role  = "CORE"
      instance_type  = "m3.xlarge"
      instance_count = "1"
      bid_price      = "0.30"
      autoscaling_policy = <<EOF
{
"Constraints": {
  "MinCapacity": 1,
  "MaxCapacity": 2
},
"Rules": [
  {
    "Name": "ScaleOutMemoryPercentage",
    "Description": "Scale out if YARNMemoryAvailablePercentage is less than 15",
    "Action": {
      "SimpleScalingPolicyConfiguration": {
        "AdjustmentType": "CHANGE_IN_CAPACITY",
        "ScalingAdjustment": 1,
        "CoolDown": 300
      }
    },
    "Trigger": {
      "CloudWatchAlarmDefinition": {
        "ComparisonOperator": "LESS_THAN",
        "EvaluationPeriods": 1,
        "MetricName": "YARNMemoryAvailablePercentage",
        "Namespace": "AWS/ElasticMapReduce",
        "Period": 300,
        "Statistic": "AVERAGE",
        "Threshold": 15.0,
        "Unit": "PERCENT"
      }
    }
  }
]
}
EOF
    },
  ]

  bootstrap_name = "runif"
  bootstrap_uri  = "s3://elasticmapreduce/bootstrap-actions/run-if"
  bootstrap_args = []
  log_uri        = "s3n://.../"

  project     = "Something"
  environment = "Staging"
}
```

## Instance Group Example

```hcl
[
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
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional\_master\_security\_groups | Additional master security groups to place the EMR EC2 instances in | string | n/a | yes |
| applications | List of EMR release applications | list | `<list>` | no |
| bootstrap\_args | List of arguments to the bootstrap action script | list | `<list>` | no |
| bootstrap\_name | Name for the bootstrap action | string | n/a | yes |
| bootstrap\_uri | S3 URI for the bootstrap action script | string | n/a | yes |
| configurations | JSON array of EMR application configurations | string | n/a | yes |
| custom\_ami\_id | Custom AMI ID to base the EMR EC2 instance on | string | n/a | yes |
| custom\_tags | Custom tags to add to the default EMR tags | map | `<map>` | no |
| environment | Name of environment this cluster is targeting | string | `"Unknown"` | no |
| instance\_groups | List of objects for each desired instance group | list | `<list>` | no |
| key\_name | EC2 key pair name | string | n/a | yes |
| log\_uri | S3 URI of the EMR log destination, must begin with `s3n://` and end with trailing | string | n/a | yes |
| name | Name of EMR cluster | string | n/a | yes |
| project | Name of project this cluster is for | string | `"Unknown"` | no |
| release\_label | EMR release version to use | string | `"emr-5.7.0"` | no |
| subnet\_id | Subnet used to house the EMR nodes | string | n/a | yes |
| termination\_protection | Switch on/off termination protection | string | `"false"` | no |
| vpc\_id | ID of VPC meant to house cluster | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| default\_ami\_id | The most recent suitable AMI ID for EMR to base on |
| iam\_emr\_autoscaling\_assume\_role\_policy | The policy that grants an entity permission to assume the EMR autoscaling role |
| iam\_emr\_autoscaling\_role | The name of the EMR autoscaling role |
| iam\_emr\_autoscaling\_role\_arn | The Amazon Resource Name (ARN) specifying the EMR autoscaling role |
| iam\_emr\_autoscaling\_role\_policy\_arn | The ARN of the policy applied to the EMR autoscaling role |
| iam\_emr\_autoscaling\_role\_unique\_id | The stable and unique string identifying the EMR autoscaling role |
| iam\_emr\_ec2\_instance\_profile\_assume\_role\_policy | The policy that grants an entity permission to assume the EC2 instance profile role |
| iam\_emr\_ec2\_instance\_profile\_policy\_arn | The ARN of the policy applied to the EC2 instance profile role |
| iam\_emr\_ec2\_instance\_profile\_role | The name of the EC2 instance profile role |
| iam\_emr\_ec2\_instance\_profile\_role\_arn | The Amazon Resource Name (ARN) specifying the EC2 instance profile role |
| iam\_emr\_ec2\_instance\_profile\_role\_unique\_id | The stable and unique string identifying the EC2 instance profile role |
| iam\_emr\_service\_assume\_role\_policy | The policy that grants an entity permission to assume the EMR service role |
| iam\_emr\_service\_role | The name of the EMR service role |
| iam\_emr\_service\_role\_arn | The Amazon Resource Name (ARN) specifying the EMR service role |
| iam\_emr\_service\_role\_policy\_arn | The ARN of the policy applied to the EMR service role |
| iam\_emr\_service\_role\_unique\_id | The stable and unique string identifying the EMR service role |
| id | The ID of the EMR cluster |
| master\_public\_dns | The public DNS name of the master EC2 instance |
| master\_security\_group\_id | The ID of the security group for master instance |
| name | The name of the cluster |
| slave\_security\_group\_id | The ID of the security group for client instance |
| tags | Tags applied to all EMR instances |
