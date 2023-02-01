FROM jenkins/jenkins:latest

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV JENKINS_USER admin
ENV JENKINS_PASS admin
EXPOSE 22
EXPOSE 8080/tcp

COPY plugins.txt /usr/share/jenkins/plugins.txt

ARG user=jenkins
USER root

RUN mkdir -p /opt/jenkins
ADD http://mirrors.jenkins.io/war-stable/2.107.1/jenkins.war /opt/jenkins/jenkins.war

RUN mkdir -p /var/jenkins_home/jobs/test_job
RUN mkdir -p /var/jenkins_home/jobs/test_job/workspace
RUN mkdir -p /var/jenkins_home/jobs/test_job/builds
RUN jenkins-plugin-cli -f usr/share/jenkins/plugins.txt --verbose


# ENV DOCKERVERSION=19.03.12
# LABEL Description="This image is derived from jenkins/agent openjdk11. \
#       It includes docker static binary"
# RUN apt-get update -y
# RUN apt-get install -y ca-certificates curl gnupg lsb-release vim
# RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKERVERSION}.tgz \
#   && tar xzvf docker-${DOCKERVERSION}.tgz --strip 1 \
#                  -C /usr/local/bin docker/docker \
#   && rm docker-${DOCKERVERSION}.tgz

RUN apt-get update -y
RUN apt-get install -y ca-certificates curl gnupg lsb-release vim
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update -y
RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
RUN update-alternatives --set iptables /usr/sbin/iptables-legacy
RUN update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

# RUN apt-get update -y && \
#     apt-get -qy full-upgrade && \
#     apt-get install -qy curl && \
#     apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin && \
#     curl -sSL https://get.docker.com/ | sh
RUN usermod -a -G docker jenkins
RUN chown -R jenkins:jenkins /var/jenkins_home

# RUN service docker start
WORKDIR /home/${user}
USER ${user}
ENV JENKINS_URL "http://localhost:8080"
RUN curl --insecure ${JENKINS_URL}/jnlpJars/jenkins-cli.jar \
   --output /jenkins/jenkins-cli.jar
CMD ["java","-jar","/jenkins/jenkins-cli.jar","-noCertificateCheck","-noKeyAuth"]
