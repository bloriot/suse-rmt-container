# suse-rmt-container
SUSE Repository Mirroring Tool (RMT) run in container
Based on: https://github.com/thkukuk/rmt-container/blob/master/podman/run-rmt-containerized.sh

## Prerequisites

Packages
* podman

Network
* access to registry.suse.com

## Script usage

Configure SCC mirroring credentials in the script (SCC_USERNAME and SCC_PASSWORD).
Then run the script to start or stop RMT.

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
