FROM python:3-alpine
ENV TARGETARCH="linux-musl-x64"

RUN apk add sudo && \
    adduser -h /home/agent -s /bin/sh -D agent && \
    echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel && \
    adduser agent wheel && \
    echo -n 'agent:agent' | chpasswd

RUN apk update && \
    apk upgrade && \
    apk add bash curl gcc git icu-libs jq musl-dev python3-dev libffi-dev openssl-dev cargo make \
            zip \
            nano
RUN apk add docker-cli

# Install Azure CLI
RUN pip install --upgrade pip
RUN pip install azure-cli
RUN pip install awscli

WORKDIR /azp/
COPY ./start.sh ./

RUN chmod +x ./start.sh && \
    chown -R agent:agent /azp

USER agent

# Another option is to run the agent as root.
# ENV AGENT_ALLOW_RUNASROOT="true"

ENTRYPOINT [ "./start.sh" ]