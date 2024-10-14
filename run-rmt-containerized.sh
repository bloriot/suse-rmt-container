#!/bin/sh

# Registry and image parameters
REGISTRY_URL=registry.suse.com/suse
MARIADB_IMAGE="mariadb:10.6"
NGINX_IMAGE="nginx:1.21"
RMT_SERVER_IMAGE="rmt-server:2.18"
# Credentials
SCC_USERNAME=<scc-mirroring-cred-username>
SCC_PASSWORD=<scc-mirroring-cred-password>
MYSQL_ROOT_PASSWORD=root

# usage
if [ $# -eq 0 ]; then
    echo "Usage: $0 [start|stop]"
    exit 0
fi

### start rmt-server
start() {
# Create volumes
mkdir -p /srv/rmt/mariadb
mkdir -p /srv/rmt/storage
mkdir -p /srv/rmt/ssl
mkdir -p /srv/rmt/vhosts.d
if [ $(getenforce) == "Enforcing" ] ; then chcon -Rt svirt_sandbox_file_t /srv/rmt ; fi

# Run mariadb
podman run -d --rm --name rmt-mariadb -p 3306:3306 -v /srv/rmt/mariadb:/var/lib/mysql -e MYSQL_DATABASE=rmt -e MYSQL_USER=rmt -e MYSQL_PASSWORD=rmt -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} ${REGISTRY_URL}/${MARIADB_IMAGE}

# Run nginx
podman run -d --rm --name rmt-nginx -p 80:80 -p 443:443 -v /srv/rmt/vhosts.d:/etc/nginx/vhosts.d -v /srv/rmt/ssl:/etc/rmt/ssl -v /srv/rmt/storage:/usr/share/rmt ${REGISTRY_URL}/${NGINX_IMAGE}

# Run rmt-server
MYSQL_HOST=`podman inspect -f "{{.NetworkSettings.IPAddress}}" rmt-mariadb`
until podman exec -it rmt-mariadb mysql -u rmt -prmt -e "show databases">/dev/null; do echo "Waiting for mariadb to be available..." ; sleep 3 ; done
podman run -d --rm --name rmt-server -p 4224:4224 -v /srv/rmt/storage:/var/lib/rmt -e MYSQL_HOST=${MYSQL_HOST} -e MYSQL_DATABASE=rmt -e MYSQL_USER=rmt -e MYSQL_PASSWORD=rmt -e SCC_USERNAME=${SCC_USERNAME} -e SCC_PASSWORD=${SCC_PASSWORD} ${REGISTRY_URL}/${RMT_SERVER_IMAGE}

echo "Running containers"
podman ps
echo
echo '"rmt-cli sync" command will run automatically. Wait a few minutes to enable products.'
}

### stop rmt-server
stop() {
echo "Stopping rmt containers (rmt-server, nginx, mariadb)"
for p in rmt-server rmt-nginx rmt-mariadb ; do podman stop $p ; done
podman ps
}

# execute commands passed as parameter
$1
