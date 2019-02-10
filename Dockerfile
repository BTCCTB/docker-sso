FROM centos:centos7
LABEL maintenaire="Damien LAGAE"
ENV SIMPLESAMLPHP_VER=1.16.3

RUN yum -y install epel-release \
    && yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm \
    && yum -y update \
    && yum-config-manager --enable remi-php72 \
    && yum -y install httpd mod_ssl php php-ldap php-mbstring php-memcache php-mcrypt php-pdo php-pear php-xml wget \
    && yum -y clean all

RUN wget https://github.com/simplesamlphp/simplesamlphp/releases/download/v$SIMPLESAMLPHP_VER/simplesamlphp-$SIMPLESAMLPHP_VER.tar.gz \
    && tar xzf simplesamlphp-$SIMPLESAMLPHP_VER.tar.gz \
    && rm simplesamlphp-$SIMPLESAMLPHP_VER.tar.gz \
    && mv simplesamlphp-$SIMPLESAMLPHP_VER /var/simplesamlphp
