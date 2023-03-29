# Docker-swarm-with-terraform-on-AWS
# **Terraform AWS EC2 Docker Swarm Cluster**

This is a Terraform configuration to create a Docker Swarm cluster in
AWS EC2.

## **Prerequisites**

To use this Terraform configuration you need:

-   An AWS account

-   The [[TerraformCLI]{.underline}](https://learn.hashicorp.com/tutorials/terraform/install-cli)

-   A SSH key to access the EC2 instances

-   Docker installed in the machine where you run Terraform

## **Usage**

1.  Clone the repository and navigate to the project directory:


```sh
git clone https://github.com/user/terraform-aws-ec2-docker-swarm-cluster.git

 cd terraform-aws-ec2-docker-swarm-cluster
```



3.  Run Terraform commands to create and manage the infrastructure:
```
terraform init
```
```
terraform plan
```
```
terraform apply
```


This Terraform configuration will create:

-   A VPC with a public subnet

-   An Internet Gateway

-   A Route Table

-   A Security Group with inbound rules to allow SSH and Docker Swarm
    > traffic

-   A TLS private key

-   An EC2 instance for each of the three roles required in a Docker
    > Swarm cluster (manager, worker1 and worker2)


# **SSH into the instances**

Once the EC2 instances are created, you can SSH into them using the key
pair that was generated earlier. You can use the ssh command with the -i
flag to specify the path to the private key file and the username
ec2-user:

```

ssh -i keypair.pem ec2-user@\<public-ip-address-of-instance\>
```
Replace \<public-ip-address-of-instance\> with the actual public IP
address of the instance that you want to connect to. 
# **Join the nodes to the Swarm**

# Configure the master and worker nodes

Enter the following command to configure the master node:
```sh
docker swarm init --advertise-addr <private ip of master node>
```
> ** Note: Make sure to use a private static IP address above. **

 Make sure you copy the command it suggests to add a worker to a swarm. We will be using this in the next step and need to use the token provided.


Now for the worker nodes. connect to the worker  EC2 instance connect sessions we will need to join all 2 to the master node using the command from above.




** Let’s check our manager node to make sure that the cluster has been configured correctly.
```sh
docker node ls
```
You can see above and confirm that there is one manager/leader node and three workers.



