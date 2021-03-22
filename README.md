# Summary
The dependencies are just within roles/policies being place for the ci (assume role) references to those will be seen within the template.

# Prep Work

We have to setup IAM roles and policy for appropirate permission to deploy ecs fargate into AWS cloud.

# How to run this project

Please make sure to confiure aws cli or setting up assume role before running this project
I have used credentials file to authenticate terraform, at line number #3

# Command to run this project

terraform apply -var-file dev



