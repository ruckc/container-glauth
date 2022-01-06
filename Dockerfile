FROM docker.io/golang:bullseye AS build

ARG GLAUTH_TAG=v2.1.0-RC1

RUN apt-get update && \
    apt-get install git make -y && \
    mkdir /src

WORKDIR /src

RUN git clone https://github.com/glauth/glauth.git && \
    cd glauth && \
    git -c advice.detachedHead=false checkout $GLAUTH_TAG && \
    cd v2 && \
    make linuxamd64 && \
    make plugin_postgres && \
    find bin -ls

FROM gcr.io/distroless/base-debian11 AS run

WORKDIR /app

COPY --from=build /src/glauth/v2/bin/linuxamd64/glauth /app/glauth
COPY --from=build /src/glauth/v2/bin/linuxamd64/postgres.so /app/postgres.so
COPY server.cfg /app/server.cfg

USER 1000

ENTRYPOINT ["/app/glauth", "-c", "/app/server.cfg"]
