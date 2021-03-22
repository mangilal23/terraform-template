terraform {
  backend "s3" {
    #---------------------------
    # NEVER CHANGE THESE VALUES
    #---------------------------
    #This will allow you to download and view your state file.
    acl                  = "bucket-owner-full-control"
    #---------------------------
    # NEVER CHANGE THESE VALUES
    #---------------------------
    #This is the bucket where to store your state file.
    bucket               = "terraform-state-mangi"

    # This ensures the state file is stored encrypted at rest in S3.
    encrypt              = true

    # This is the region of S3 bucket.
    region               = "ap-south-1"
    
    #---------------------------
    # Configurable Options
    #---------------------------

    # This will be used as a folder in which you store the state file.
    workspace_key_prefix = "assignment"
    
    # Key is the state file's file name.
    key                  = "fargate-template"

  }
}
