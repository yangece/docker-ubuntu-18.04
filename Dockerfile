ARG BASE_IMAGE
FROM ${BASE_IMAGE}

#ENV set -ex \
#    && http_proxy=${http_proxy} \
#    https_proxy=${http_proxy} \
#    no_proxy=${no_proxy}  
#ENV DEBIAN_FRONTEND=noninteractive 

#RUN  echo 'Acquire::http::Proxy "http://PITC-Zscaler-Americas-Alpharetta3PR.proxy.corporate.ge.com:80";' >> /etc/apt/apt.conf.d/01proxy  \
#  && echo 'Acquire::https::Proxy "http://PITC-Zscaler-Americas-Alpharetta3PR.proxy.corporate.ge.com:80";' >> /etc/apt/apt.conf.d/01proxy

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
       curl \
       apt-utils \
       lsb-release \
       apt-transport-https \
       software-properties-common \
       ca-certificates \
  \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
     iputils-ping \
     build-essential \
     python3.8 python3.8-venv \
     python3-pip \
     python3.8-dev \
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

RUN python3.8 -m venv /venv
ENV PATH=/venv/bin:$PATH

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
#RUN bash ubuntu_sim_ros_melodic.sh

# Enable the dynamic setting of the user
COPY provision_container.sh /usr/local/bin/
RUN chmod 1777 /usr/local/bin/provision_container.sh

ENTRYPOINT ["/usr/local/bin/provision_container.sh"]
CMD ["/bin/bash"]

ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
LABEL org.label-schema.vendor="HazMap team" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0-rc1"
