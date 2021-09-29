FROM debian:stable-slim

RUN apt-get update

RUN apt-get -y dist-upgrade \
	&& apt-get -y install \
		curl \
		g++ \
		gcc \
		git \
		gnuplot \
		libncurses5-dev \
		make \
		python3 \
	&& apt-get -y autoremove \
	&& apt-get -y autoclean \
	&& mkdir /app

WORKDIR /app

COPY test.sh curl_data.py imgcat ./

RUN chmod -R 701 ./ \
	&& chown -R nobody:nogroup ./

USER nobody

ENTRYPOINT ["/app/test.sh"]