# Docker: SSO

Dockerized SSO for development purpose only !

## Overview
This Docker image contains a deployed SimpleSAMLphp IdP/SP based on PHP 7.2 running on Appache HTTP Server 2.4 and a ldap server running on 389 Directory Server. This image is based on the latest CentOS 7 base. This image is build for development purpose only !

```
[rootdir]
|-- etc/
|   |-- httpd/
|   |   |-- conf/       - The Apache HTTP Server configuration
|   |-- slapd/
|   |   |-- conf/       - The 389 Directory Server configuration
|   |   |-- import/     - The ldif files to import into 389 DS
|-- var/
|   |-- log/
|   |   |-- httpd/      - The log files for Apache HTTP Server 
|   |-- simplesamlphp/  - The base SimpleSAMLphp directory
|   |   |-- conf/       - The SimpleSAMLphp configuration directory
|   |-- www/
|   |   |-- html/       - The base Apache HTTP Server document root directory
```

## Creating a SimpleSAMLphp Configuration
Image adopters should follow the SimpleSAMLphp documentation (https://simplesamlphp.org/docs/stable/) to configure the IdP/SP and/or other features. Include other directories that one would often customized, such as the images, css, and application files themselves. 

## Using the Image
You should use this image as a base image for one's own IdP/SP deployment. The directory structure could look like:

```
[rootdir]
|-- .dockerignore
|-- Dockerfile
|-- etc/
|   |-- supervisor.conf
|   |-- etc/
|   |   |-- httpd/
|   |   |-- conf.d/
|   |   |   |-- httpd.conf
|   |   |-- slapd/
|   |   |   |-- conf/
|   |   |   |   |-- ds-setup.inf
|   |   |   |-- import/
|   |   |   |   |-- users.ldif
|   |   |-- supervisor-conf.d/
|   |   |   |-- 01-ldap.conf
|   |   |   |-- 02-httpd.conf
|-- var/
|   |-- simplesamlphp/
|   |   |-- config/
|   |   |   |-- config.php
|   |-- www/
|   |   |-- html/
|   |   |   |-- index.php
```

Next, assuming you create a Dockerfile similar to this example:

```
FROM enabel/dev-sso

MAINTAINER <your_contact_email>

COPY etc-httpd/ /etc/httpd/
COPY etc-slapd/ /etc/slapd/
COPY var-simplesamlphp/ /var/simplesamlphp/
COPY var-www/ /var/www/
```

The dependant image can be built by running:

```
docker pull centos:centos7
docker build --tag="<org_id>/ourapplication:<version>" .
```

> This will download the base image from the Docker Hub repository. Next, your files are overlaid replacing the base image's counter-parts.

Now, execute the new/customized image:

```
$ docker run -d --name="ourapplication-local-test" <org_id>/ourapplication
```

> This is the base command-line used to start the container. The container will likely fail to initialize if this limited command-line is used. You'll likely need to specify additional parameters to start-up the container.

## Run-time Parameters
Start the SSO will take several parameters. The following parameters can be specified when `run`ning a new container:

### Port Mappings
The image exposes three ports. `80` is the for standard browser-based HTTP communication. `443` is the standard browser-based HTTPS/TLS communication port. `9001` is the supervisord default status page. These ports will need to be mapped to the Docker host so that communication can occur.

* `-P`: Used to indicate that the Docker Service should map all exposed container ports to ephemeral host ports. Use `docker ps` to see the mappings.
* `-p <host>:<container>`: Explicitly maps the host ports to the container's exposed ports. This parameters can be used multiple times to map multiple sets of ports. `-p 443:443` would make the service accessible on `https://<docker_host_ip>/simplesaml/`. 

### Environmental variables
No explicit envinonmental variables are used by this container. Any that SimpleSAMLphp might use can be used per the application documentation.

### Volume Mount
The container does not explicitally need any volumes mapped for operation, but the option does exist using the following format:

* `-v hostDir:containerDir`

It maybe desirable to map things like  `/var/log/httpd/` or `/var/simplesamlphp/cert/` to host-side storage.

## Notables
There are a few things that implementors should be aware of.

### Browser-based TLS Certificate and Key
Adapters should generate their own private key and get the CSR signed by a trusted certificate authority. The resulting files should be included in the image (directly or mounted to the container at start-up). The standard Apache HTTPD TLS config can be changed by adding/modifying the files in `/etc/httpd/conf.d/`.

### Logging 
This image does not use the standard Docker logging mechanism, but the native supervisord logging.

## Building from source:
 
```
$ docker build --tag="<org_id>/sso" gitlab.enabel.be/enabel/docker-sso
```

## Authors/Contributors

  * Damien LAGAE (<damien.lagae@enabel.be>)
