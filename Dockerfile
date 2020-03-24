FROM docker:latest

RUN apk add --no-cache curl jq python nodejs npm py-pip \
    && pip install awscli \
    && npm install -g @angular/cli \
    && curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin

CMD ["/bin/sh"]
