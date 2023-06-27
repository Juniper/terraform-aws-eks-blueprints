# Summarized Deployment guide
### Setting up deployment VM environment 

#### Prerequisites:
 
* **Install AWS CLI:** 
  * Install AWS CLI by following the instructions in the following: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
  * Verify the cli works by running the following command
    * aws --version
* **Install kubectl**
  * Install Kubectl by running the below command (THis will differ depending on the OS you use. Below steps are for Linux)
    * ``curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"``  
    * ``sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl``
    * ``kubectl version --client``
 
 
* Install Terraform:
  * Follow the steps in the following link (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) to install Terraform for the OS you use. The below steps are for installaing in Amazon Linux 
    * ``sudo yum install -y yum-utils``
    * ``sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo``
    * ``sudo yum -y install terraform``
    * ``terraform -help``
 
* **AWS account setup:**
  * Get the AWS credentials from the administrator 
  * Use the below commands to export your credentials in the terminal session you plan to run Terraform
    * ``export AWS_ACCESS_KEY_ID=<enter access key id here>``
    * ``export AWS_SECRET_ACCESS_KEY=<enter secret access key here>``
  * Export the AWS Region you want to install CN2 in
    * ``export AWS_REGION=us-east-1`` 
 
* Setup EKS cluster with CN2: (https://github.com/Juniper/terraform-aws-eks-blueprints/blob/awseks-23.1/examples/eks-cluster-with-cn2/README.md)
  * Run the below commands to clone cn2 Terraform blueprints  
    * ``git clone https://github.com/Juniper/terraform-aws-eks-blueprints.git``
    * ``git branch``
    * ``git checkout awseks-23.1``
  * Follow the below steps to configure terraform variables
    * ``cd examples/eks-cluster-with-cn2/``
    * vi variables.tf
    * Add Juniper enterprise hub token in the variables file
  * Run terraform init to get the required plugins for terraform
    * ``terraform init``
  * Run plan and apply terraform
    * terraform plan
    * terraform apply

* Setup Kubeconfig for you cluster
  * Run the following command to create the kubeconfig file. Make sure to update the CLUSTERNAME.
    * ``aws eks update-kubeconfig --name <CLUSTERNAME>``
    * ``export KUBECONFIG=<userhome>/.kube/config``  
    * Check if EKS nodes are healthy
      * ``kubectl get nodes``
    * Check if CN2 pods are running
      * ``kubectl get pods -n contrail``    
  
* Optional: Install demo app Boutique using the tgz provided. 
  * Un tar the tgz and follow the below steps
  * cd CN2\ Examples/boutique-manifests/isolated-namespace/
  * kubectl apply -f adservice.yaml
  * kubectl apply -f cartservice.yaml
  * kubectl apply -f emailservice.yaml
  * kubectl apply -f frontend.yaml
  * kubectl apply -f productcatalogservice.yaml
  * kubectl apply -f recommendationservice.yaml
  * kubectl apply -f checkoutservice.yaml
  * kubectl apply -f loadgenerator.yaml
  * kubectl apply -f redis.yaml
  * kubectl apply -f currencyservice.yaml
  * kubectl apply -f paymentservice.yaml
  * kubectl apply -f shippingservice.yaml
  * kubectl get pod -A | grep ns-
 
### Cleanup and teardown:
 
* Delete Boutique app
  * cd CN2\ Examples/boutique-manifests/isolated-namespace/
  * kubectl delete -f adservice.yaml
  * kubectl delete -f cartservice.yaml
  * kubectl delete -f emailservice.yaml
  * kubectl delete -f frontend.yaml
  * kubectl delete -f productcatalogservice.yaml
  * kubectl delete -f recommendationservice.yaml
  * kubectl delete -f checkoutservice.yaml
  * kubectl delete -f loadgenerator.yaml
  * kubectl delete -f redis.yaml
  * kubectl delete -f currencyservice.yaml
  * kubectl delete -f paymentservice.yaml
  * kubectl delete -f shippingservice.yaml
* Make sure the frontend AWS loadbalancer created by Boutique app is deleted by running the below command
  * `` aws elb describe-load-balancers``  
  * If a loadbalancer exists in the matching VPC ID where CN2 EKS install. This needs tobe deleted first by logging into the AWS UI under loadbalancers page in EC2 service.
  * Note: Make sure all AWS resources created by Boutique app is deleted before triggering delete of Terraform resources.
* **Uninstall CN2** 
  * ``curl -fsSL -o unintall.tar.gz https://github.com/Juniper/cn2-helm/tree/main/uninstall``
  * ``tar -xvf unintall.tar.gz``
  * ``cd uninstall ``
  * ``./uninstall.sh``
* **Uninstall AWS Resources created by Terraform**
  * From within the terraform blueprints directory trigger the following commands
    * ``terraform destroy``   
 
### Troubleshooting Guide
* **Subnet deletion error**
  * Log: Error: deleting EC2 Subnet (subnet-0c2ecdfb9aa92d807): DependencyViolation: The subnet 'subnet-0c2ecdfb9aa92d807' has dependencies and cannot be deleted.
  * Problem overview: This issue is seen when there are AWS resources that are created out of band from what we create from Terraform. Terraform will not be able to delete any resources unless it is created using terraform.
  * Solution: Login to AWS Console UI and check for any resources that got created within the subnet listed in the error log and delete it before starting the terraform again.
* 