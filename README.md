# AndyWebServices IaC

## Description

Repo contains code that maintains AndyWebServices (AWS) infrastructure. AWS in this repo **alway** refers to 
AndyWebServices and **not** some sort of similar Seattle-based cloud provider thing.

Code in this repo is meant to work, but not necessarily meant to be well organized. This dizzying array
of various frameworks and inconsistent methods of deployment are a result of Andy taste-testing various
different IaC tools.

## Table of Contents

### Aliases

Sets up OpenTofu DNS records to control my SimpleLogin alias domains. This should probably be moved to Andy's personal
GitHub...

### Cloudflare

#### Zone AWS

Setups up DNS records for `andywebservices.com`, GitHub Pages, and ProtonMail MX servers related to AWS.

### Docker Composes

TODO write docs for this

### k3s - Kubernetes Cluster

#### Ansible Scripts

TODO Write docs for this

#### k1 - A raspberry pi cluster

A self-hosted, high-availability k3s (light-weight kubernetes) cluster running on raspberry pi4's. This folder contains
OpenTofu configs. Aside from cluster setup via `k3sup` and `kube-vip`, all other services can be configured via 
OpenTofu. Critical infra services are listed below:

* `kube-vip` for virtual IP, load balancing, and control plane leader election 
* `longhorn` for distributed persistent volumes
  * With regular backups to a CIFS NAS
* `traefik` for host routing via IngressRoute
  * `cert-manager` for SSL certs stored in config maps (as opposed to PVs)
    * `cloudflare` for issuing SSL certs via dns-01 method
  * `tailscale` for VPN entrypoints, ie services that are only accessible after connecting to AWS's Tailscale Tailnet

User services hosted include:
* Actual Server for budgeting
* Home Assistant dummy route
  * Home Assistant services are run on a HA Yellow Board
* Homepage for displaying available services
* Karakeep for smart bookmarking of webpages

### Tailscale 

#### AWS Tailnet

OpenTofu files for managing ACL rules for the AWS Tailnet.

#### NextDNS

Custom DNS records for AWS Tailnet are configured via NextDNS's rewrite settings. Because both Pulumi and OpenTofu lack
a NextDNS registry provider, a custom Pulumi provider is implemented in Python.
