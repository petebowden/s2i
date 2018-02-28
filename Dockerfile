# base-image
FROM registry.access.redhat.com/rhel7
# TODO: Put the maintainer name in the image metadata
# LABEL maintainer="Your Name <your@email.com>"

# TODO: Rename the builder environment variable to inform users about application you provide them
# ENV BUILDER_VERSION 1.0

# TODO: Set labels used in OpenShift to describe the builder image
#LABEL io.k8s.description="Platform for building xyz" \
#      io.k8s.display-name="builder x.y.z" \
#      io.openshift.expose-services="8080:http" \
#      io.openshift.tags="builder,x.y.z,etc."
ENV TOMCAT_VERSION=8.5.28 \
    TOMCAT_MAJOR=8 \
    MAVEN_VERSION=3.0.5 \
    TOMCAT_DISPLAY_VERSION=8.5 \
    CATALINA_HOME=/tomcat \
    JAVA="java-1.8.0-openjdk java-1.8.0-openjdk-devel" \
    JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8 \
    POM_PATH=.
# TODO: Install required packages here:
# RUN yum install -y ... && yum clean all -y
RUN INSTALL_PKGS="tar unzip bc which lsof $JAVA" && \
    yum install -y  $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y && \
    (curl -v https://www.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | \
    tar -zx -C /usr/local) && \
    ln -sf /usr/local/apache-maven-$MAVEN_VERSION/bin/mvn /usr/local/bin/mvn && \
    mkdir -p $HOME/.m2 && \
    mkdir -p /tomcat && \
    (curl -v https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz | tar -zx --strip-components=1 -C /tomcat) && \
    mkdir -p /opt/s2i/destination


# TODO (optional): Copy the builder files into /opt/app-root
# COPY ./<builder_folder>/ /opt/app-root/
RUN mkdir /opt/app-root
# TODO: Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image
# sets io.openshift.s2i.scripts-url label that way, or update that label
COPY ./s2i/bin/ /usr/libexec/s2i

# TODO: Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:1001 /opt/app-root
RUN chown -R 1001:0 /tomcat && chown -R 1001:0 $HOME && \
    chmod -R ug+rwx /tomcat

# This default user is created in the openshift/base-centos7 image
USER 1001

# TODO: Set the default port for applications built using this image
# EXPOSE 8080

# TODO: Set the default CMD for the image
# CMD ["/usr/libexec/s2i/usage"]
