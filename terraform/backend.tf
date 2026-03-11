terraform {

 backend "s3" {

   bucket       = "tasktracker-terraform-state-demo"
   key          = "infra/terraform.tfstate"
   region       = "ap-south-1"
   use_lockfile = true

 }

}