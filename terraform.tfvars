name               = "calibre-web"
environment        = "prod"
availability_zones = ["eu-west-1a", "eu-west-1b"]
# private_subnets       = ["10.0.0.0/20", "10.0.32.0/20"]
public_subnets        = ["10.0.16.0/20", "10.0.48.0/20"]
container_image       = "ghcr.io/linuxserver/calibre-web:latest"
container_port        = 8083
service_desired_count = 1
region                = "eu-west-1"
container_environment = [
  { name = "TZ", value = "Europe/Rome" },
  { name = "DOCKER_MODS", value = "linuxserver/mods:universal-calibre" },
  { name = "OAUTHLIB_RELAX_TOKEN_SCOPE", value = 1 },
]
