ARG BASE_SERVER_IMAGE=temporalio/base-server:1.15.12

FROM ${BASE_SERVER_IMAGE} AS temporal-server
ARG TARGETARCH
ARG TEMPORAL_SHA=unknown
ARG TCTL_SHA=unknown

WORKDIR /etc/temporal

ENV TEMPORAL_HOME=/etc/temporal
EXPOSE 6933 6934 6935 6939 7233 7234 7235 7239

# TODO switch WORKDIR to /home/temporal and remove "mkdir" and "chown" calls.
RUN addgroup -g 1000 temporal
RUN adduser -u 1000 -G temporal -D temporal
RUN mkdir /etc/temporal/config
RUN chown -R temporal:temporal /etc/temporal/config
RUN chmod g+w /etc/temporal/config

RUN set -eux; \
    GROUP="temporal"; \
    USER="allianz_temporal"; \
    GROUP_FILE="/etc/group"; \
    \
    # Create user directly in /etc/passwd and /etc/shadow
    echo "${USER}:x:1000810000:1000810000::/home/${USER}:" >> /etc/passwd; \
    echo "${USER}:!:$(($(date +%s) / 60 / 60 / 24)):0:99999:7:::" >> /etc/shadow; \
    \
    # Add user to the 'temporal' group
    awk -F: -v grp="$GROUP" -v usr="$USER" 'BEGIN {OFS=FS} \
    $1 == grp { \
        if ($NF == "") { \
            $NF = usr; \
        } else { \
            split($NF, members, ","); \
            found=0; \
            for (m in members) if (members[m] == usr) found=1; \
            if (!found) $NF = $NF "," usr; \
        } \
    } \
    {print} \
    ' "$GROUP_FILE" > "${GROUP_FILE}.tmp" && mv "${GROUP_FILE}.tmp" "$GROUP_FILE"; \
    \
    # Create the user's home directory
    mkdir -p "/home/${USER}"; \
    chown "${USER}:${GROUP}" "/home/${USER}"

USER temporal

# store component versions in the environment
ENV TEMPORAL_SHA=${TEMPORAL_SHA}
ENV TCTL_SHA=${TCTL_SHA}

# binaries
COPY ./build/${TARGETARCH}/tctl /usr/local/bin
COPY ./build/${TARGETARCH}/tctl-authorization-plugin /usr/local/bin
COPY ./build/${TARGETARCH}/temporal-server /usr/local/bin
COPY ./build/${TARGETARCH}/temporal /usr/local/bin

# configs
COPY ./temporal/config/dynamicconfig/docker.yaml /etc/temporal/config/dynamicconfig/docker.yaml
COPY ./temporal/docker/config_template.yaml /etc/temporal/config/config_template.yaml

# scripts
COPY ./docker/entrypoint.sh /etc/temporal/entrypoint.sh
COPY ./docker/start-temporal.sh /etc/temporal/start-temporal.sh

ENTRYPOINT ["/etc/temporal/entrypoint.sh"]
