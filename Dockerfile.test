FROM gcc:6.1
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN apt-get update && apt-get install -qq -y software-properties-common sudo

ADD . /app
WORKDIR /app

RUN make -e ci-dependencies
