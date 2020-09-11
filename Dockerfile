FROM docker:latest

ARG ANGULAR

ENV GLIBC_VER=2.31-r0


RUN apk --no-cache add \
        binutils \
        curl \
         # INSTALL glibc compiler
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && apk add --no-cache \
        glibc-${GLIBC_VER}.apk \
        glibc-bin-${GLIBC_VER}.apk \
        # Install aws cli v2
    && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && aws/install \
        # Remove aws-cli build files and unnecessary modules
    && rm -rf \
        awscliv2.zip \
        aws \
        /usr/local/aws-cli/v2/*/dist/aws_completer \
        /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
        /usr/local/aws-cli/v2/*/dist/awscli/examples \
        # Install python and node js
    && apk add --no-cache jq python3 nodejs npm py3-pip \
        # Install kubectl
    && curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin \
    && apk --no-cache del \
        binutils \
        curl \
    && rm glibc-${GLIBC_VER}.apk \
    && rm glibc-bin-${GLIBC_VER}.apk \
    && rm -rf /var/cache/apk/*


COPY ecr-tag-helper.sh /root/bin/ecr-tag-helper.sh
RUN chmod u+x /root/bin/ecr-tag-helper.sh

RUN if [ "$ANGULAR" = true ] ; then npm install -g @angular/cli ; else echo "No angular cli because build-arg ANGULAR = $ANGULAR" ; fi

CMD ["/bin/sh"]
