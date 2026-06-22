# ---------------------------------------------------------
# CENTRAL HUB: Security Groups & Ingress Restrictions
# ---------------------------------------------------------
resource "aws_security_group" "hub_internal_alb_sg" {
  provider    = aws.hub
  name        = "${var.hub_vpc_name}-internal-alb-sg"
  description = "Allows incoming async metadata syncs from Spokes via Peering"
  vpc_id      = module.hub_vpc.vpc_id

  ingress {
    description = "Strict ingress exclusively from the Spoke VPC CIDR"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.spoke_vpc_cidr]
  }

  egress {
    description = "Allow routing out to local resources"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.hub_vpc_cidr]
  }
}

resource "aws_security_group" "hub_lambda_router_sg" {
  provider    = aws.hub
  name        = "${var.hub_vpc_name}-lambda-router-sg"
  description = "Controls egress rules for Central Lambda Router"
  vpc_id      = module.hub_vpc.vpc_id

  egress {
    description = "Allows Lambda to send synchronous writes to Spoke ALBs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.spoke_vpc_cidr]
  }
}

# ---------------------------------------------------------
# REGIONAL SPOKE: Zero-Trust Security Groups
# ---------------------------------------------------------
resource "aws_security_group" "spoke_internal_alb_sg" {
  provider    = aws.spoke
  name        = "${var.spoke_vpc_name}-internal-alb-sg"
  description = "Allows synchronous write execution from the Hub Lambda"
  vpc_id      = module.spoke_vpc.vpc_id

  ingress {
    description = "Strict ingress exclusively from the Central Hub CIDR"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.hub_vpc_cidr]
  }

  egress {
    description = "Allow internal routing inside Spoke"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.spoke_vpc_cidr]
  }
}

resource "aws_security_group" "spoke_fargate_sg" {
  provider    = aws.spoke
  name        = "${var.spoke_vpc_name}-fargate-sg"
  description = "Controls egress for Fargate Tasks"
  vpc_id      = module.spoke_vpc.vpc_id

  egress {
    description = "Allows async proxy write up the peering tunnel to Hub ALB"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.hub_vpc_cidr]
  }
}
