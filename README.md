# suse-rmt-container
SUSE Repository Mirroring Tool (RMT) run in container

## Prerequisites

Packages
* podman

Network
* access to registry.suse.com

## Script usage

```bash
# start rmt components
./run-rmt-containerized.sh start

# stop rmt components
./run-rmt-containerized.sh stop
```

## Mirror a product

```bash
podman exec -it rmt-server rmt-cli sync
podman exec -it rmt-server rmt-cli products enable SLES/15.6/x86_64
podman exec -it rmt-server rmt-cli mirror
```
