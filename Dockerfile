FROM centos:centos7
LABEL maintenaire="Damien LAGAE"
ENV SIMPLESAMLPHP_VER=1.16.3

RUN yum -y install epel-release \
    && yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm \
    && yum -y update \
    && yum-config-manager --enable remi-php72 \
    && yum -y install httpd mod_ssl php php-ldap php-mbstring php-memcache php-mcrypt php-pdo php-pear php-xml wget 389-ds-base 389-adminutil supervisor \
    && yum -y clean all

# SimpleSamlPHP
#---------------
RUN wget https://github.com/simplesamlphp/simplesamlphp/releases/download/v$SIMPLESAMLPHP_VER/simplesamlphp-$SIMPLESAMLPHP_VER.tar.gz \
    && tar xzf simplesamlphp-$SIMPLESAMLPHP_VER.tar.gz \
    && rm simplesamlphp-$SIMPLESAMLPHP_VER.tar.gz \
    && mv simplesamlphp-$SIMPLESAMLPHP_VER /var/simplesamlphp

RUN echo $'\nSetEnv SIMPLESAMLPHP_CONFIG_DIR /var/simplesamlphp/config\nAlias /simplesaml /var/simplesamlphp/www\n \
<Directory /var/simplesamlphp/www>\n \
    Require all granted\n \
</Directory>\n' \
       >> /etc/httpd/conf/httpd.conf
# httpd as service
COPY httpd-foreground /usr/local/bin/
# SimpleSamlPHP Config
COPY var/simplesamlphp/config/ /var/simplesamlphp/config/
COPY var/simplesamlphp/metadata/ /var/simplesamlphp/metadata/
# httpd config
COPY etc/httpd/conf/ssp.conf /etc/httpd/conf.d/ssp.conf
COPY var/www/html /var/www/html

# LDAP
#------
RUN mkdir -p /etc/slapd/conf && mkdir -p /etc/slapd/import
COPY etc/slapd/conf/ds-setup.inf /etc/slapd/conf/
COPY etc/slapd/import/users.ldif /etc/slapd/import/

# The 389-ds setup will fail because the hostname can't reliable be determined, so we'll bypass it and then install.
RUN useradd ldapadmin \
    && rm -fr /var/lock /usr/lib/systemd/system \
    # The 389-ds setup will fail because the hostname can't reliable be determined, so we'll bypass it and then install. \
    && sed -i 's/checkHostname {/checkHostname {\nreturn();/g' /usr/lib64/dirsrv/perl/DSUtil.pm \
    # Not doing SELinux \
    && sed -i 's/updateSelinuxPolicy($inf);//g' /usr/lib64/dirsrv/perl/* \
    # Do not restart at the end \
    && sed -i '/if (@errs = startServer($inf))/,/}/d' /usr/lib64/dirsrv/perl/* \
    && setup-ds.pl --silent --file /etc/slapd/conf/ds-setup.inf \
    && /usr/sbin/ns-slapd -D /etc/dirsrv/slapd-dir \
    && while ! curl -s ldap://localhost:389 > /dev/null; do echo waiting for ldap to start; sleep 1; done; \
    ldapadd -H ldap:/// -f /etc/slapd/import/users.ldif -x -D "cn=Directory Manager" -w password

# Supervisor
#------------
COPY etc/supervisor.conf /etc/supervisor.conf
COPY etc/supervisor/conf.d/ /etc/supervisor/conf.d/

EXPOSE 80 443 9001

CMD supervisord -c /etc/supervisor.conf