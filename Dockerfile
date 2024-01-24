FROM ubuntu:22.04

LABEL maintainer="user <user@docker.com>"

ENV VNC_SCREEN_SIZE=1024x768

ENV TZ=Asia/Shanghai
ENV LC_ALL=C

COPY app /

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
	&& DEBIAN_FRONTEND=noninteractive \
	apt-get install -y --no-install-recommends \
	gnupg2 \
	fonts-noto-cjk \
	pulseaudio \
	supervisor \
	xvfb \
	x11vnc \
	eterm \
	ca-certificates \
	locales

ADD https://packages.microsoft.com/keys/microsoft.asc \
	/tmp/

RUN apt-key add /tmp/microsoft.asc \
	&& echo "deb https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge.list \
	&& apt-get update \
	&& apt-get install -y microsoft-edge-stable \
	&& DEBIAN_FRONTEND=noninteractive apt-get -f --yes install

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
	echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
	echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen && \
	echo "LANG=zh_CN.UTF-8" >> /etc/default/locale && \
	echo "LANGUAGE=zh_CN:zh" >> /etc/default/locale

RUN apt-get clean \
	&& rm -rf /var/cache/* /var/log/apt/* /var/lib/apt/lists/* /tmp/* \
	&& useradd -m -G pulse-access edge \
	&& usermod -s /bin/bash edge \
	&& ln -s /update /usr/local/sbin/update

USER edge

VOLUME ["/home/edge"]

WORKDIR /home/edge

EXPOSE 5900

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
