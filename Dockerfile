FROM ubuntu

ARG snapshot=lts-7.10
ARG commit=ghc-8.0.2-rc1
ARG extraopts=''

RUN apt-get update
	# because this is on it's own line, remember to build no-cache
	# to force new versions

RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:hvr/ghc -y
RUN apt-get update

RUN apt-get install -y --no-install-recommends \
	autoconf \
	automake \
	bzip2 \
	curl \
#	dblatex \
#	docbook-utils \
#	docbook-xsl \
	freeglut3-dev \
	g++ \
	gcc \
	git \
	libc-dev \
	libffi-dev \
	libgl1-mesa-dev \
	libglu1-mesa-dev \
	libgmp-dev \
	libtinfo-dev \
	libtool \
	libxml2-utils \
	llvm \
	make \
	ncurses-dev \
	patch \
	python \
	sudo \
	vim \
	xutils-dev \
	zlib1g-dev \
  wget \
  ghc-8.0.1 \
  cabal-install-1.24


RUN apt-get install -y alex-3.1.7 happy-1.19.5


# Stackage package init
COPY debian-bootstrap.sh debian-bootstrap.sh
RUN ls
RUN chmod +x debian-bootstrap.sh
RUN ./debian-bootstrap.sh

# setup environment
ENV LANG     C.UTF-8
ENV LC_ALL   C.UTF-8
ENV LANGUAGE C.UTF-8

RUN useradd -u 3300 -m -d /home/ghc -s /bin/bash ghc && \
    echo "ghc ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ghc && chmod 0440 /etc/sudoers.d/ghc

ENV HOME /home/ghc
WORKDIR /home/ghc
USER ghc

RUN git clone --recursive git://git.haskell.org/ghc.git
COPY build.mk ghc/mk/build.mk
WORKDIR ghc
RUN git reset --hard $commit
RUN git submodule update
RUN ./boot
RUN env
ENV PATH /opt/ghc/8.0.1/bin:$PATH
ENV PATH /opt/happy/1.19.5/bin:$PATH
ENV PATH /opt/alex/3.1.7/bin:$PATH
ENV PATH /opt/cabal/1.24/bin:$PATH
RUN ./configure
RUN make -j4

RUN sudo make install



RUN wget https://www.stackage.org/$snapshot/cabal.config

RUN cat cabal.config | sed 's/ ==/-/g' | sed '/installed,/d' | sed '1,4d' | sed 's/constraints://g' | sed 's/,$//g' | sed "s/^[ \t]*//" > packages
RUN cat packages
RUN cabal update
ENV PATH /usr/local/bin:$PATH
RUN /usr/local/bin/ghc --version
RUN for i in $(cat packages); do echo $i; cabal install -w /usr/local/bin/ghc  $i; done;


