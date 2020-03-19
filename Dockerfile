FROM ubuntu:latest

RUN apt-get update \
    && apt-get install -y curl unzip docker jq python3 python3-pip systemd \
    && curl -sL https://deb.nodesource.com/setup_13.x | bash - \
    && curl -fsSL https://get.docker.com -o get-docker.sh \
    && sh get-docker.sh \
    && apt-get install -y nodejs \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip
RUN ["sh", "./aws/install"]

CMD ["/bin/bash"]
