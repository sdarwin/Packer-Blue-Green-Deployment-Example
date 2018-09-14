
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_launch_configuration" "web" {
  lifecycle { create_before_destroy = true }

  image_id       = "${var.ami}"
  instance_type  = "${var.instance_type}"
  key_name       = "${var.key_name}"
  security_groups = ["${aws_security_group.web.id}"]
}

resource "null_resource" "launch_configuration_backup" {
  triggers = {
    #run every time
    the_uuid = "${uuid()}"
  }
  #depends_on = ["aws_launch_configuration.web"]
  provisioner "local-exec" {
    command = <<EOT
      timestamp=$(date +%Y-%m-%d-%H-%M-%S)
      AWS_ACCESS_KEY_ID=${var.access_key} AWS_SECRET_ACCESS_KEY=${var.secret_key} AWS_REGION=${var.region} /usr/bin/aws autoscaling create-launch-configuration --launch-configuration-name ${aws_launch_configuration.web.name}-BACKUPCOPY-${var.environment}-$timestamp \
--image-id ${aws_launch_configuration.web.image_id} \
--key-name ${aws_launch_configuration.web.key_name} \
--security-groups ${aws_security_group.web.id} \
--instance-type ${aws_launch_configuration.web.instance_type} 

EOT
  }
}

resource "aws_autoscaling_group" "web" {
  lifecycle { create_before_destroy = true }

  name                 = "${var.environment}-web"
  launch_configuration = "${aws_launch_configuration.web.name}"
  desired_capacity     = "${var.nodes}"
  min_size             = "${var.nodes}"
  max_size             = "${var.nodes}"
  min_elb_capacity     = "${var.nodes}"
  availability_zones   = ["${split(",", var.azs)}"]
  vpc_zone_identifier  = ["${split(",", var.subnet_ids)}"]
  #load_balancers       = ["${aws_lb.web.id}"]
  target_group_arns    = ["${aws_lb_target_group.web.id}"]
}

resource "aws_security_group" "web" {
  name        = "${var.environment}-web"
  description = "${var.environment}-web"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "allow_all_in" {
  type            = "ingress"
  from_port       = 0
  to_port         = 65535
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.web.id}" 
}

resource "aws_security_group_rule" "allow_all_out" {
  type            = "egress"
  from_port       = 0
  to_port         = 65535
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.web.id}" 
}

resource "aws_lb" "web" {
  name            = "${var.environment}-web"
  internal        = false
  security_groups = ["${aws_security_group.web.id}"]
  subnets         = ["${split(",", var.subnet_ids)}"]

  enable_deletion_protection = true

  tags {
    env = "${var.environment}"
  }
}

resource "aws_lb_target_group" "web" {
  name     = "${var.environment}-web"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = "${var.vpc_id}"

  health_check {
    interval = 30
    path = "/lbcheck.html"
    port = "traffic-port"
    protocol = "HTTPS"
    timeout = 5
  }
}

resource "aws_lb_listener" "web-https" {
  load_balancer_arn = "${aws_lb.web.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${var.certificatearn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.web.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "web-http" {
  load_balancer_arn = "${aws_lb.web.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.web.arn}"
    type             = "forward"
  }
}

