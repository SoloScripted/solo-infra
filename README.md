# solo-infra
Core infrastructure for SoloScripted using Terraform. Provisions GitHub integrations and AWS environment.
## Getting Started

To get started with solo-infra, you'll need to have Terraform installed. You can then clone this repository and run `terraform init` to initialize the Terraform backend.

## Modules

This repository contains the following Terraform modules:

* **github**: Provisions GitHub repositories, teams, and webhooks.
* **aws**: Provisions an AWS VPC, EKS cluster, and other AWS resources.

## Usage

To deploy the infrastructure, run `terraform apply` from the root of this repository. You can also deploy individual modules by navigating to the module directory and running `terraform apply` from there.

## Contributing

We welcome contributions to solo-infra! Please see our [contributing guidelines](CONTRIBUTING.md) for more information.
