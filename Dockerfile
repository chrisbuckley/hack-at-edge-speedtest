FROM debian

RUN apt-get update

RUN apt-get -y dist-upgrade

RUN apt-get -y install \
	g++ \
	gcc \
	git \
	gnuplot \
	libncurses5-dev \
	make \
	python2 

RUN mkdir /app

WORKDIR /app

RUN git clone --recurse-submodules https://github.com/eddieantonio/imgcat.git

RUN cd imgcat \
	&& make \
	&& make install \
	&& cd .. \
	&& rm -rf imgcat

COPY down.sh curl_data.py curl.out.png ./

RUN chmod -R +x ./ \
	&& chown -R nobody:nogroup ./

# USER nobody

CMD /bin/bash