import os

import requests
from pulumi.dynamic import Resource, ResourceProvider, CreateResult

_nextdns_endpoint_rewrites = "https://api.nextdns.io/profiles/{profile_id}/rewrites/"
_nextdns_endpoint_rewrites_id = "https://api.nextdns.io/profiles/{profile_id}/rewrites/{rewrite_id}"

api_token = os.getenv("NEXTDNS_API_TOKEN")
if not api_token:
    raise ValueError("NEXTDNS_API_TOKEN environment variable not set")

headers = {
    "X-Api-Key": f"{api_token}",
    "Content-Type": "application/json",
}


class NextDNSProvider(ResourceProvider):
    def create(self, props):
        # Replace with your real Cloudflare API logic
        src = props['src']
        content = props['content']
        profile_id = props['profile_id']

        response = requests.post(
            _nextdns_endpoint_rewrites.format(profile_id=profile_id),
            headers=headers,
            json={
                "name": src,
                "content": content
            }
        )

        response.raise_for_status()
        record_id = response.json()['data']['id']
        return CreateResult(id_=record_id, outs=props)

    def delete(self, rewrite_id, props):
        profile_id = props['profile_id']
        response = requests.delete(
            _nextdns_endpoint_rewrites_id.format(profile_id=profile_id, rewrite_id=rewrite_id),
            headers=headers
        )
        response.raise_for_status()


class NextDNSRewrite(Resource):
    def __init__(self, src, content, profile_id, opts=None):
        super().__init__(NextDNSProvider(), f"{src} -> {content}", {
            "src": src,
            "content": content,
            "profile_id": profile_id
        }, opts)
