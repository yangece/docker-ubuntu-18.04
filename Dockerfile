ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive 

RUN apt-get update \
  && apt-get install -y -qq --no-install-recommends \
       curl \
       apt-utils \
       lsb-release \
       apt-transport-https \
       software-properties-common \
       ca-certificates \
  \
  && apt-get install -y -qq \
     iputils-ping \
     build-essential \
     python3 \
     python-pip \
     python-virtualenv \
     python-dev \
     vim \
     git \
     sudo \
     xterm \
     xauth \
     xorg \
     dbus-x11 \
     xfonts-100dpi \
     xfonts-75dpi \
     xfonts-cyrillic \
     wget \
  \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
  && apt-key fingerprint 0EBFCD88 \
  && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  && apt-get update && apt-get -y install -qq --no-install-recommends docker-ce \
  && apt-get -y autoremove \
  && apt-get -y clean \
  && rm -rf /var/lib/apt/lists/* \
  \
  && mkdir /tmp/.X11-unix \
  && chmod 1777 /tmp/.X11-unix \
  && chown root:root /tmp/.X11-unix/

# Install latest su-exec
RUN  set -ex; \
     \
     curl -o /usr/local/bin/su-exec.c https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c; \
     \
     fetch_deps='gcc libc-dev'; \
     apt-get update; \
     apt-get install -y --no-install-recommends $fetch_deps; \
     rm -rf /var/lib/apt/lists/*; \
     gcc -Wall \
         /usr/local/bin/su-exec.c -o/usr/local/bin/su-exec; \
     chown root:root /usr/local/bin/su-exec; \
     chmod 0755 /usr/local/bin/su-exec; \
     rm /usr/local/bin/su-exec.c; \
     \
     apt-get purge -y --auto-remove $fetch_deps

RUN wget https://raw.githubusercontent.com/PX4/Devguide/master/build_scripts/ubuntu_sim_ros_melodic.sh
RUN bash ubuntu_sim_ros_melodic.sh

# Enable the dynamic setting of the user
COPY provision_container.sh /usr/local/bin/
RUN chmod 1777 /usr/local/bin/provision_container.sh

ENTRYPOINT ["/usr/local/bin/provision_container.sh"]
CMD ["/bin/bash"]

ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
LABEL org.label-schema.vendor="XYZ Company" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0-rc1"
