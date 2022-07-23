# cicd-pipeline-aws-terraform-eks-fargate-train-schedule-auto-deployment

Prerequisite:

1.  Install terraform and configure aws cli on Jenkins worker nodes
    
        1.  Terraform
        2.  AWS CLI

Usage:

2.  Create a CI/CD pipeline on Jenkins with GitHub hook trigger for GITScm polling configured

3.  Select "Pipeline script from SCM" for Pipeline Definition -> Select Git under SCM

4.  Provide the url of the repository

5.  Click Save

6.  On GitHub configure web-hook on your the "cicd-pipeline-aws-terraform-eks-fargate-train-schedule-auto-deployment" repository

7.  Manually Perform the first build

8.  When the build successfully completes, copy the Application Load Balancer address outputted to the screen and create a CNAME record where

            Host: train-schedule
            Value: k8s-default-trainsch-**********.us-east-1.elb.amazonaws.com

9.  NOTE:

            When changes are made and pushed back to the repository, Jenkins will perform the required CI/CD.


