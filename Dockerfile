FROM debian

RUN apt-get update

RUN apt-get -y dist-upgrade

RUN apt-get -y install \
	curl \
	g++ \
	gcc \
	git \
	gnuplot \
	libncurses5-dev \
	make \
	python3

RUN mkdir /app

WORKDIR /app

COPY test.sh curl_data.py requirements.sh imgcat ./

RUN chmod -R +x ./ \
	&& chown -R nobody:nogroup ./

USER nobody

ENTRYPOINT ["/app/test.sh"]