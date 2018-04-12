FROM dcm4che/wildfly:12.0.0-3.4.3

ENV DCM4CHEE_ARC_VERSION="5.13.0"
ENV DCM4CHE_VERSION="dcm4chee-arc-$DCM4CHEE_ARC_VERSION-mysql" \
    MYSQL_CONNECTOR="mysql-connector-java-5.1.36"
ENV LDAP_HOST=ldap \
    LDAP_PORT=389 \
    LDAP_BASE_DN=dc=dcm4che,dc=org \
    LDAP_ROOTPASS=secret \
    MYSQL_HOST=127.0.0.1 \
    MYSQL_PORT=3306 \
    MYSQL_DATABASE=pacsdb \
    MYSQL_USER=pacs \
    MYSQL_PASSWORD=pacs \
    ARCHIVE_DEVICE_NAME=dcm4chee-arc \
    HTTP_PORT=8080 \
    HTTPS_PORT=8443 \
    MANAGEMENT_HTTP_PORT=9990 \
    WILDFLY_ADMIN_USER=admin \
    WILDFLY_ADMIN_PASSWORD= \
    KEYSTORE=dcm4chee-arc/key.jks \
    KEYSTORE_PASSWORD=secret \
    KEY_PASSWORD=secret \
    KEYSTORE_TYPE=JKS \
    TRUSTSTORE=dcm4chee-arc/cacerts.jks \
    TRUSTSTORE_PASSWORD=secret \
    WILDFLY_EXECUTER_MAX_THREADS=100 \
    WILDFLY_PACSDS_MAX_POOL_SIZE=50

# download binary distribution
RUN curl -O -L https://astuteinternet.dl.sourceforge.net/project/dcm4che/dcm4chee-arc-light5/$DCM4CHEE_ARC_VERSION/$DCM4CHE_VERSION.zip \
    && unzip $DCM4CHE_VERSION.zip \
    && cd $DCM4CHE_VERSION \
    && for module in jboss-modules/*; do unzip $module -d $JBOSS_HOME; done \
    && mv deploy/dcm4chee-arc-ear-$DCM4CHEE_ARC_VERSION-mysql.ear /docker-entrypoint.d/deployments/

# download mysql java connector, decompress and move to final location
RUN curl -L https://downloads.mysql.com/archives/get/file/$MYSQL_CONNECTOR.tar.gz | tar xz \
    && mv $MYSQL_CONNECTOR/$MYSQL_CONNECTOR-bin.jar $JBOSS_HOME/modules/com/mysql/main/

# copy configuration files
COPY configuration /docker-entrypoint.d/configuration

CMD ["standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0", "-c", "dcm4chee-arc.xml"]
