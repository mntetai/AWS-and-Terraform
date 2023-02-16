vpc module to create resources in a custom vpc

inputs:

none

outputs :

vpc_id - id of vpc created (string)
public_subnets - ids of public subnets created (list of strings)
private_subnets - ids of private subnets created (list of strings)
private_subnet_count - number of private sunbents created (number)
my_nat_gw - nat gateway resource to be consumed (resource)

variables:

public_cidrs - public subnets cidr blocks (list of strings)
private_cidrs - private subnet cidr blocks (list of strings)
vpc_cidr_range - vpc cider range (string)
internet_cidr_range - internet cidr range (needed for routing)
enable_dns_hostnames - default is true
map_public_ip_on_launch - default is true
private_subnet_count - default is 2
public_subnet_count - default is 2