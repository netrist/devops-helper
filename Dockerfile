FROM docker:latest

ARG ANGULAR

RUN apk add --no-cache curl jq python3 nodejs npm py3-pip \
    && pip3 install awscli \
    && curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin

COPY ecr-tag-helper.sh /root/bin/ecr-tag-helper.sh
RUN chmod u+x /root/bin/ecr-tag-helper.sh

RUN if [ "$ANGULAR" = true ] ; then npm install -g @angular/cli ; else echo "No angular cli because build-arg ANGULAR = $ANGULAR" ; fi

CMD ["/bin/sh"]
