# Yomali [not production ready]

This repo will setup

- Setup an instance for MySQL in GCP with SSH access.
- Setup an instance for HAProxy in GCP with SSH access.
- Using Ansible, Install & configure the MySQL server.
- Using Ansible, Install & configure the HAProxy server. Configure this to route queries to the MySQL server
- Ensure the HAProxy config exposes a status page.

# Requisites

- terraform =>
    Terraform v1.3.8
- gcloud =>
    Google Cloud SDK 418.0.0
    bq 2.0.85
    bundled-python3-unix 3.9.16
    core 2023.02.13
    gcloud-crc32c 1.0.0
    gsutil 5.20
- ansible => 
    ansible [core 2.11.12] 

# Structure

The repo structure is divided into:

- config => ansible playbooks for mysql and haproxy
- infra => terraform scripts to deploy the following high-level diagram:

https://drive.google.com/file/d/1bchWYtM2kGUn2fJx9Ibtf5lHePo_xTQs/view?usp=sharing

# Usage

Every folder has its own Makefile, actions are documented inside of it, to execute an action, simply issue:

$ make <action>

The flow is:

- go to infra folder and run make dev-apply
- wait for it to finish
- test connection to bastion host, make sure it has ansible and mysql client installed, e.g. $ ansible --version, $ mysql********
- go to config folder and run make requisites, make copy, make mysql, make haproxy

# TODO

- improve user experience, reduce manual steps after infra deployment
- haproxy playbook not making cache before hand
- tcp flow from haproxy to mysql not working yet