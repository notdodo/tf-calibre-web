# tf-calibre-web

Terraform deployment for Calibre Web on ECS Fargate.

## Calibre database init

1. Create a free EC2 instance to mount the EFS volume
2. Mount the EFS volume inside the EC2
3. Create the `/config` and `/books` folders inside the mounted EFS volume
4. Give open permissions to the two folder `chmod 777 -R /config` and `chmod 777 -R /books` (calibre-web will take care to set the correct permissions on provisioning)
5. Import you old Calibre database or the empty one inside `/books`
