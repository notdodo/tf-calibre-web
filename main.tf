module "iam" {
  source = "./iam"
  name   = var.name
}
module "vpc" {
  source             = "./vpc"
  name               = var.name
  region             = var.aws-region
  cidr               = var.cidr
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
  environment        = var.environment
}

module "security_groups" {
  source          = "./security_groups"
  name            = var.name
  vpc_id          = module.vpc.id
  environment     = var.environment
  container_port  = var.container_port
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}

module "alb" {
  source              = "./alb"
  name                = var.name
  vpc_id              = module.vpc.id
  subnets             = module.vpc.public_subnets
  environment         = var.environment
  alb_security_groups = [module.security_groups.alb_sg]
  health_check_path   = var.health_check_path
}

module "efs" {
  source                   = "./efs"
  name                     = var.name
  environment              = var.environment
  private_subnets          = module.vpc.private_subnets
  subnets_count            = length(module.vpc.private_subnets)
  efs_security_groups      = [module.security_groups.efs_sg]
  iam_efs_role_name        = module.iam.ecs_task_role_name
  iam_efs_role_arn         = module.iam.ecs_task_role_arn
  inline_policy_efs_access = module.iam.inline_policy_efs_access
}

module "ecs" {
  source                      = "./ecs"
  name                        = var.name
  environment                 = var.environment
  region                      = var.aws-region
  subnets                     = module.vpc.private_subnets
  aws_alb_target_group_arn    = module.alb.aws_alb_target_group_arn
  ecs_service_security_groups = [module.security_groups.ecs_tasks_sg]
  container_port              = var.container_port
  container_cpu               = var.container_cpu
  container_memory            = var.container_memory
  container_image             = var.container_image
  container_volume_config     = module.efs.efs_config_id
  container_volume_books      = module.efs.efs_books_id
  container_volume            = module.efs.efs_id
  service_desired_count       = var.service_desired_count
  container_environment       = var.container_environment
  task_execution_role         = module.iam.ecs_task_execution_role_arn
  task_role                   = module.iam.ecs_task_role_arn
}
