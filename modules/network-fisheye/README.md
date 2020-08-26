# Network Modules

Terraform resources to build a VPC, and bastion node, and related security groups.

## Preferred Usage

It will be common to use the `app-network` module in conjuntion with the `management-network` module which brings in all of the dependencies for VPC, bastion, subnets, keys, etc.  The `app-network` module replaces the `standard-network` which is deprecated.

The `app-network` is a network that hosts a shared set of infrastructure resources used to host applications. One or more `app-networks` are peered with a `management-network`.     

The `management-network` provides the entry point to manage resources in the app networks through a bastion host.  Other ingress options may be added to the management network as needed, for instance a VPN server.  Resources in the `app-network` would need to include the 'allow_all_management_vpc_traffic' security group so that access from the management VPC is allowed.

The standard-network module is a deprecated way of using these resources. All of the dependencies between the three resources are handled in the terraform configuration. Inputs are defined below. All outputs from VPC, Bastion, and Keys are outputed in this module as well.

## Inputs/Outputs

If a default value is not given, Terraform will require a value as an input. Either as a tfvars file, or from the command line.

### Management-Network Inputs

| Value | Description | Default |
|-------|-------------|---------|
| region | AWS region | |
| tags | Tags for AWS resources | |
| cidr | VPC cidr block | 172.16.0.0/20 |
| public_cidrs | VPC public cidr block | 172.16.0.0/23,172.16.2.0/23,172.16.4.0/23 |
| private_cidrs | VPC private cidr block | 172.16.8.0/23,172.16.10.0/23,172.16.12.0/23 |
| bastion\_instance\_type | EC2 instance type for Bastion | t2.small |
| provider\_role\_arn |   The role arn that is to be assumed to apply this modules resources.  Relates to a specific IAM role and AWS account.|
| ssh\_ingress\_cidr | A list of cidr notation IP address ranges for where incoming SSH traffic can originate | \["159.182.1.4/32"\] (Pearson VPC) |

### Management-Network Outputs

All outputs from VPC, Bastion, and Keys are available.

### App-Network Inputs

| Value | Description | Default |
|-------|-------------|---------|
| region | AWS region | |
| tf_state_s3_bucket | The bucket holding the Terraform state file for the management network | |
| tf_state_region | The region of the tf_state_s3_bucket | |
| peered_management_network_environment | The name of the peered management netwwork | |
| tags | Tags for AWS resources | |
| cidr | VPC cidr block | 172.16.0.0/20 |
| public_cidrs | VPC public cidr block | 172.16.0.0/23,172.16.2.0/23,172.16.4.0/23 |
| private_cidrs | VPC private cidr block | 172.16.8.0/23,172.16.10.0/23,172.16.12.0/23 |

### App-Network Outputs

All outputs from VPC, Bastion, and Keys are available.

### Standard-Network Inputs

| Value | Description | Default |
|-------|-------------|---------|
| region | AWS region | |
| tags | Tags for AWS resources | |
| cidr | VPC cidr block | 172.16.0.0/20 |
| public_cidrs | VPC public cidr block | 172.16.0.0/23,172.16.2.0/23,172.16.4.0/23 |
| private_cidrs | VPC private cidr block | 172.16.8.0/23,172.16.10.0/23,172.16.12.0/23 |
| bastion\_instance\_type | EC2 instance type for Bastion | t2.small |
| ssh\_ingress\_cidr | A list of cidr notation IP address ranges for where incoming SSH traffic can originate | \["159.182.1.4/32"\] (Pearson VPC) |
| forward\_only\_sshkey | Filename of a public SSH key file used for tunneling only type connections | |

### Standard-Network Outputs

All outputs from VPC, Bastion, and Keys are available.

### VPC Inputs

| Value | Description | Default |
|-------|-------------|---------|
| region | AWS region | |
| tags | Tags for AWS resources | |
| cidr | VPC cidr block  | 172.16.0.0/20 |
| public_cidrs | VPC public cidr block  | 172.16.0.0/23,172.16.2.0/23,172.16.4.0/23 |
| private_cidrs | VPC private cidr block | 172.16.8.0/23,172.16.10.0/23,172.16.12.0/23 |
| main_route_table_id | Route table ID for the default/main VPC route table |
| public_route_table | Route table ID for the shared public route table |
| private_route_tables | List of route tables for private subnets |


### VPC Outputs

| Value | Description |
|-------|-------------|
| vpc_id | Id for AWS resource |
| cidr | The cidr for generated vpc |
| private_subnet_ids | List of private subnet ids |
| public_subnet_ids | List of public subnet ids |
| nat_gateway_ids | ids for generated NAT |
| nat_gateway_public_ips | ips of the generated NAT |
| main_route_table_id | Route table ID for the default/main VPC route table |
| public_route_table | Route table ID for the shared public route table |
| private_route_tables | List of route tables for private subnets |


### Bastion Inputs

| Value | Description | Default |
|-------|-------------|---------|
| region | AWS region | |
| tags | Tags for AWS resources | |
| vpc_id | AWS VPC id | |
| vpc_cidr | cidr block for given vpc | |
| public_subnet_ids | Public subnet ids for given vpc | |
| key_name | Key-pair to load onto EC2 bastion instance | |
| instance_type | EC2 instance type | t2.small |
| ssh\_ingress\_cidr | A list of cidr notation IP address ranges for where incoming SSH traffic can originate | \["159.182.1.4/32"\] (Pearson VPC) |
| route53_zone | The hosted zone domain name | pearsondev.com. |
| forward\_only\_sshkey | Filename of a public SSH key file used for tunneling only type connections | |

### Bastion Outputs

| Value | Description |
|-------|-------------|
| user | SSH login user |
| private_ip | private ip address |
| public_ip | public ip address |
| security_group | security group name |
| dns_name | route53 entry |

### Keys Inputs

| Value | Description | Default |
|-------|-------------|---------|
| region | AWS region | |
| key_name | Name of ssh key to use to create key-pair in AWS | |

### Keys Outputs

| Value | Description |
|-------|-------------|
| name | Name of generated key-pair |

## Developers Guide

For guidelines about contributing and using, see the [developers-guide](https://gilligan.pearsondev.com/terraform-modules/developers-guide)
