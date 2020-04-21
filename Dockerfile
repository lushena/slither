FROM ubuntu:bionic

LABEL name slither
LABEL src "https://github.com/trailofbits/slither"
LABEL creator trailofbits
LABEL dockerfile_maintenance trailofbits
LABEL desc "Static Analyzer for Solidity"

RUN apt update \
  && apt upgrade -y \
  && apt install -y build-essential git python3 python3-dev python3-setuptools wget software-properties-common

# RUN wget https://github.com/ethereum/solidity/releases/download/v0.4.25/solc-static-linux \
#  && chmod +x solc-static-linux \
#  && mv solc-static-linux /usr/bin/solc
ADD ./solc-static-linux ./ 
RUN chmod +x solc-static-linux \
 && mv solc-static-linux /usr/bin/solc

RUN useradd -m slither
USER slither

# If this fails, the solc-static-linux binary has changed while it should not.
RUN [ "c9b268750506b88fe71371100050e9dd1e7edcf8f69da34d1cd09557ecb24580  /usr/bin/solc" = "$(sha256sum /usr/bin/solc)" ]

COPY --chown=slither:slither . /home/slither/slither
WORKDIR /home/slither/slither

ADD ./pysha3-1.0.2.tar.gz ./
RUN chmod +x pysha3-1.0.2.tar.gz \
 && tar xzvf pysha3-1.0.2.tar.gz \
 && cd pysha3-1.0.2 \
 && python3 setup.py install --user

ADD ./prettytable-0.7.2.tar.gz ./
RUN chmod +x prettytable-0.7.2.tar.gz \
 && tar xzvf prettytable-0.7.2.tar.gz \
 && cd prettytable-0.7.2 \
 && python3 setup.py install --user

ADD ./crytic-compile-0.1.7.tar.gz ./
RUN chmod +x crytic-compile-0.1.7.tar.gz \
 && tar xzvf crytic-compile-0.1.7.tar.gz \
 && cd crytic-compile-0.1.7 \
 && python3 setup.py install --user
 
RUN python3 setup.py install --user
ENV PATH="/home/slither/.local/bin:${PATH}"
CMD /bin/bash
