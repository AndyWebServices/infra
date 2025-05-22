import os

from dotenv import load_dotenv
from pulumi_docker import Provider

from .uptime_kuma import uptime_kuma

load_dotenv()

def run():
    if not os.environ.get('DOCKER_HOST'):
        raise RuntimeError('Please set the DOCKER_HOST environment variable')

    provider = Provider(
        "overwatch-provider",
        host=os.environ.get('DOCKER_HOST'),
    )
    uptime_kuma(provider)
