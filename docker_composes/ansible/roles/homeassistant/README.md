# Home Assistant Role

## Important!!

Do not forget to set the following in your homeassistant's `/config/configuration.yaml`[^1]

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - XXX.XXX.XXX.XXX # Add the IP address of the proxy server. You can find this in the Home Assistant logs
```

[^1] https://community.home-assistant.io/t/home-assistant-400-bad-request-docker-proxy-solution/322163
