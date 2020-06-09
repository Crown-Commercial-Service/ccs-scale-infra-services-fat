# ccs-scale-infra-services-fat

## SCALE Find a Thing (FaT) Services

### Overview
This repository contains a complete set of configuration files and code to provision SCALE FAT services into the AWS cloud.  The infrastructure code is written in [Terraform](https://www.terraform.io/) and contains the following primary components:

- Shared Services (as ECS Fargate tasks, the source code for the Docker images sits in other repositories) 
    - [Guided Match](https://github.com/Crown-Commercial-Service/ccs-scale-guided-match-service)
    - [Decision Tree Service](https://github.com/Crown-Commercial-Service/ccs-scale-decision-tree-service)
    - [Decision Tree Database](https://github.com/Crown-Commercial-Service/ccs-scale-decision-tree-db)
    - [Lookup Service](https://github.com/Crown-Commercial-Service/ccs-scale-lookup-service)
    - [Buyer UI](https://github.com/Crown-Commercial-Service/ccs-scale-ui)

### Prerequisites

TODO
