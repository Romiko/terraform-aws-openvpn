resource "aws_ecs_task_definition" "default" {
  family = "openvpn-${var.name}"

  execution_role_arn = "${aws_iam_role.ecs_task.arn}"
  task_role_arn      = "${aws_iam_role.ecs_task.arn}"

  volume {
    name      = "openvpn-${var.name}"
    host_path = "/mnt/efs/openvpn-${var.name}"
  }

  container_definitions = <<EOT
[
  {
    "name": "${var.name}",
    "image": "${var.image}",
    "memoryReservation": 256,
    "essential": true,
    "portMappings": [
      {
        "hostPort": 1194,
        "containerPort": 1194,
        "protocol": "udp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.default.name}",
          "awslogs-region": "${data.aws_region.current.name}",
          "awslogs-stream-prefix": "${var.name}"
      }
    },
    "linuxParameters": {
      "capabilities": {
        "add": [ "NET_ADMIN" ]
      }
    },
    "environment": [
      { "name": "DOMAIN_NAME", "value": "${var.domain_name}" },
      { "name": "S3_BUCKET", "value": "${aws_s3_bucket.vpn.id}" },
      { "name": "AWS_DEFAULT_REGION", "value": "${data.aws_region.current.name}" }
    ],
    "mountPoints": [
      {
        "sourceVolume": "openvpn-${var.name}",
        "containerPath": "/etc/openvpn"
      }
    ]
  }
]
EOT
}
