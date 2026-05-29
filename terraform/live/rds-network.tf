resource "aws_db_subnet_group" "private" {
  name       = "project-bedrock-db-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "project-bedrock-db-subnet-group"
  }
}

resource "aws_security_group" "rds_mysql" {
  name        = "project-bedrock-rds-mysql-sg"
  description = "Allow MySQL traffic from EKS nodes"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "project-bedrock-rds-mysql-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_mysql_from_eks_nodes" {
  security_group_id            = aws_security_group.rds_mysql.id
  referenced_security_group_id = module.eks.node_security_group_id

  ip_protocol = "tcp"
  from_port   = 3306
  to_port     = 3306

  description = "Allow MySQL from EKS worker nodes"
}

resource "aws_vpc_security_group_egress_rule" "rds_mysql_egress_all" {
  security_group_id = aws_security_group.rds_mysql.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  description = "Allow all outbound traffic"
}

resource "aws_security_group" "rds_postgres" {
  name        = "project-bedrock-rds-postgres-sg"
  description = "Allow PostgreSQL traffic from EKS nodes"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "project-bedrock-rds-postgres-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_postgres_from_eks_nodes" {
  security_group_id            = aws_security_group.rds_postgres.id
  referenced_security_group_id = module.eks.node_security_group_id

  ip_protocol = "tcp"
  from_port   = 5432
  to_port     = 5432

  description = "Allow PostgreSQL from EKS worker nodes"
}

resource "aws_vpc_security_group_egress_rule" "rds_postgres_egress_all" {
  security_group_id = aws_security_group.rds_postgres.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  description = "Allow all outbound traffic"
}
