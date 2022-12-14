# EKS Cluster Deployment with Juniper CN2 as CNI

This example deploys the following Basic EKS Cluster with VPC

- Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Creates EKS Cluster Control plane with one managed node group(desired nodes as 3)
- Deploys Juniper CN2 as EKS cluster CNI


For more details checkout [CN2](https://www.juniper.net/us/en/products/sdn-and-orchestration/contrail/cloud-native-contrail-networking.html) docs

## How to Deploy in GreenField

### Prerequisites

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
4. [AWS Account Permission for Running Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-build)

### Minimum IAM Policy

> **Note**: The policy resource is set as `*` to allow all resources, this is not a recommended practice.

You can find the policy [here](min-iam-policy.json)


### Deployment Steps

#### Step 1: Clone the repo using the command below

```sh
git clone https://github.com/Juniper/terraform-aws-eks-blueprints.git
```
#### Step 2: Add your imagepullSecret to access enterprise-hub.juniper.net repo and/or any other CN2 config details

```sh
cd examples/eks-cluster-with-cn2/
vi main.tf
```


#### Step 3: Run Terraform INIT

Initialize a working directory with configuration files

```sh
cd examples/eks-cluster-with-cn2/
terraform init
```

#### Step 4: Run Terraform PLAN

Verify the resources created by this execution

```sh
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform plan
```

#### Step 5: Finally, Terraform APPLY

**Deploy the pattern**

```sh
terraform apply
```

Enter `yes` to apply.

### Configure `kubectl` and test cluster

EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster.
This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step 6: Run `update-kubeconfig` command

`~/.kube/config` file gets updated with cluster details and certificate from the below command

    aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>

#### Step 7: List all the worker nodes by running the command below

    kubectl get nodes

#### Step 8: List all the pods running in `kube-system` namespace

    kubectl get pods -n kube-system

#### Step 9: List all the pods running in all namespace

    kubectl get pods -A

#### Step 10: Remove aws-node daemonset
   
```sh
   kubectl -n kube-system delete ds aws-node
```
#### Step 11: login to nodes remove file /etc/cni/net.d/10-aws.conflist and reboot the nodes

There are various ways to login to nodes follow AWS [documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-methods.html) for more information

## How to Deploy Juniper CN2 in BrownField(When you have AWS EKS running with AWS VPC CNI)

Steps for Installing CN2 using helm chart

##### Step 1: Installing CN2 helm chart

```sh
helm repo add cn2 https://juniper.github.io/cn2-helm/
helm install cn2eks cn2/cn2-eks --set imagePullSecret="" <provide base64 imagepullsecret>
```
##### Step 2: Remove aws-node daemonset

```sh
   kubectl -n kube-system delete ds aws-node
```
#### Step 3: login to nodes remove file /etc/cni/net.d/10-aws.conflist and reboot the nodes

There are various ways to login to nodes follow AWS [documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-methods.html) for more information
    
## Cleanup

To clean up your environment, destroy the Terraform modules in reverse order.

Destroy the Kubernetes Add-ons, EKS cluster with Node groups and VPC

For uninstall CNI checkout [doc](https://github.com/Juniper/cn2-helm/blob/main/uninstall/README.md)

```sh
cd examples/eks-cluster-wth-cn2
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks_blueprints" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
```

Finally, destroy any additional resources that are not in the above modules

```sh
terraform destroy -auto-approve
```
## Troubleshooting

If any namespace gets stuck in terminating state while clean up run below command to clean up and run terraform destroy again

```sh
NS=`kubectl get ns |grep Terminating | awk 'NR==1 {print $1}'` && kubectl get namespace "$NS" -o json   | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/"   | kubectl replace --raw /api/v1/namespaces/$NS/finalize -f -
```
