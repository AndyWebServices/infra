import os

import pulumi
import pulumi_cloudflare as cloudflare
import pulumi_command as command
import pulumi_docker as docker
from dotenv import load_dotenv
from pulumi import ResourceOptions
from pulumi_command.remote import ConnectionArgs
from pulumi_docker import Provider
from pulumi_docker.outputs import ContainerPort, ContainerVolume, ContainerLabel, ContainerNetworksAdvanced

load_dotenv()

HOSTNAME = 'uptime'
CONTAINER_NAME = 'uptime-kuma'
ROUTER_NAME = 'uptime_kuma'
VOLUME_HOST_PATH = f'/home/{os.environ.get("USERNAME")}/docker/composes/{CONTAINER_NAME}-docker/data'
DOCKER_NETWORK = 'lsio'
DOCKER_IMAGE = 'louislam/uptime-kuma:beta'
URL = f'uptime.{os.environ['DOMAIN_NAME']}'
CNAME = f'overwatch.{os.environ['DOMAIN_NAME']}'
CERT_PROVIDER = 'letsencrypt'


def _url(provider: Provider):
    if not os.environ.get('CLOUDFLARE_API_TOKEN'):
        raise RuntimeError('Please set the CLOUDFLARE_API_TOKEN environment variable')

    uptime_url = cloudflare.DnsRecord(
        f"{CONTAINER_NAME}-url",
        name=URL,
        content=CNAME,
        ttl=1,
        type='CNAME',
        zone_id=pulumi.Config().require('zoneId'),
        opts=ResourceOptions(provider=provider, delete_before_replace=True)
    )
    return uptime_url


def _image(provider: Provider):
    uptime_kuma_image = docker.RemoteImage(f'{CONTAINER_NAME}-image', name=DOCKER_IMAGE,
                                           opts=ResourceOptions(provider=provider))
    return uptime_kuma_image


def _container(provider: Provider, uptime_kuma_image):
    uptime_kuma_mkdir_volume = command.remote.Command(
        f'{CONTAINER_NAME}-mkdir',
        connection=ConnectionArgs(host=os.environ.get('HOSTNAME'), user=os.environ.get('USERNAME')),
        create=f'mkdir -p {VOLUME_HOST_PATH}'
    )

    uptime_kuma = docker.Container(
        f'{CONTAINER_NAME}-container',
        name=CONTAINER_NAME,
        image=uptime_kuma_image.image_id,
        labels=[
            ContainerLabel(label='traefik.enable', value='true'),
            ContainerLabel(label=f'traefik.http.routers.{ROUTER_NAME}.rule',
                           value=f'Host(`{HOSTNAME}.{os.environ['DOMAIN_NAME']}`)'),
            ContainerLabel(label=f'traefik.http.routers.{ROUTER_NAME}.entrypoints', value='websecure'),
            ContainerLabel(label=f'traefik.http.routers.{ROUTER_NAME}.tls', value='true'),
            ContainerLabel(label=f'traefik.http.routers.{ROUTER_NAME}.tls.certresolver', value=CERT_PROVIDER),
            ContainerLabel(label=f'traefik.http.services.{ROUTER_NAME}.loadbalancer.server.port', value='3001')
        ],
        networks_advanced=[
            ContainerNetworksAdvanced(
                name=DOCKER_NETWORK
            )
        ],
        ports=[
            ContainerPort(
                internal=3001,
                external=3001,
            )
        ],
        restart='unless-stopped',
        volumes=[
            ContainerVolume(
                host_path=VOLUME_HOST_PATH,
                container_path='/app/data',
            )
        ],
        opts=ResourceOptions(
            delete_before_replace=True,
            provider=provider,
            depends_on=[uptime_kuma_mkdir_volume]
        )
    )
    return uptime_kuma


def uptime_kuma(provider: Provider):
    _url(provider)
    uptime_kuma_image = _image(provider)
    _container(provider, uptime_kuma_image)
