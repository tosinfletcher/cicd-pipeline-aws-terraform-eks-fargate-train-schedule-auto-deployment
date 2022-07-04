# cicd-pipeline-aws-terraform-eks-fargate-train-schedule-auto-deployment

Prerequisite:

1.  Install terraform and configure aws cli on Jenkins worker nodes
    
        1.  Terraform
        2.  AWS CLI

Usage:

2.  Creade a CI/CD pipeline on Jenkins with GitHub hook trigger for GITScm polling configured

3.  Select "Pipeline script from SCM" for Pipeline Definition

4.  Configure web-hook on your the "cicd-pipeline-aws-terraform-eks-fargate-train-schedule-auto-deployment" repository

5.  Manually Perform the first build

6.  When changes are made and pushed back to the repository, Jenkins will perform the required CI/CD.
