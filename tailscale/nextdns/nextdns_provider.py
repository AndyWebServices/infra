import os

import requests
from pulumi.dynamic import Resource, ResourceProvider, CreateResult, ReadResult, DiffResult

_nextdns_endpoint_rewrites = "https://api.nextdns.io/profiles/{profile_id}/rewrites/"
_nextdns_endpoint_rewrites_id = "https://api.nextdns.io/profiles/{profile_id}/rewrites/{rewrite_id}"

api_token = os.getenv("NEXTDNS_API_TOKEN")
if not api_token:
    raise ValueError("NEXTDNS_API_TOKEN environment variable not set")

headers = {
    "X-Api-Key": f"{api_token}",
    "Content-Type": "application/json",
}

nextdns_profile_id = os.getenv("NEXTDNS_PROFILE_ID")


class NextDNSProvider(ResourceProvider):
    def read(self, id_, props):
        response = requests.get(
            _nextdns_endpoint_rewrites.format(profile_id=nextdns_profile_id),
            headers=headers,
        )

        result = next((d for d in response.json()['data'] if d.get('id') == id_), None)

        if result is None:
            return ReadResult(
                id_=None,
                outs=props
            )
        else:
            return ReadResult(id_=id_, outs=props | result)

    def diff(self, id_: str, old_inputs: dict, new_inputs: dict) -> DiffResult:
        if any(old_inputs.get(k, '') != new_inputs.get(k, '') for k in ['name', 'content']):
            return DiffResult(
                changes=True,
                replaces=['content', 'name'],
                delete_before_replace=True
            )
        else:
            return DiffResult(changes=False)

    def create(self, props):
        # Replace with your real Cloudflare API logic
        name = props['name']
        content = props['content']

        response = requests.post(
            _nextdns_endpoint_rewrites.format(profile_id=nextdns_profile_id),
            headers=headers,
            json={
                "name": name,
                "content": content
            }
        )

        response.raise_for_status()
        print(response.json())
        record_id = response.json()['data']['id']
        return CreateResult(id_=record_id, outs=props)

    def delete(self, rewrite_id, props):
        response = requests.delete(
            _nextdns_endpoint_rewrites_id.format(profile_id=nextdns_profile_id, rewrite_id=rewrite_id),
            headers=headers
        )
        response.raise_for_status()


class NextDNSRewrite(Resource):
    def __init__(self, name, content, opts=None):
        super().__init__(NextDNSProvider(), f"{name} -> {content}", {
            "name": name,
            "content": content
        }, opts)
