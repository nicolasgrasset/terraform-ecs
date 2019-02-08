# logs.tf

variable "namespace" {
  description = "Namespace of the cluster"
}

# Set up cloudwatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/${var.namespace}-app"
  retention_in_days = 30

  tags {
    Name = "${var.namespace}-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name = "${var.namespace}-log-stream"
  log_group_name = "${aws_cloudwatch_log_group.log_group.name}"
}

#
# Output
#

output "aws_cloudwatch_log_group_name" {
  value = "${aws_cloudwatch_log_group.log_group.name}"
}