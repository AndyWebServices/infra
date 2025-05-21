# common role


## Overview
Performs the following:
- Installs Tailscale VPN
- Installs Docker
- Sets up these Docker network
  - Docker networks will be bridge networks

## Arguments
```yaml
tailscale_authkey: 'ts-XXXX' # Required
common_docker_networks: [] # Required
```
