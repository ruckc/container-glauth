FROM docker.io/golang:bullseye AS build

ARG GLAUTH_TAG=v2.0.0

RUN apt-get update && \
    apt-get install git make -y && \
    mkdir /src

WORKDIR /src

RUN git clone https://github.com/glauth/glauth.git && \
    cd glauth && \
    git -c advice.detachedHead=false checkout $GLAUTH_TAG && \
    make bindata && \
    make linux64 && \
    make bin/postgres.so

FROM gcr.io/distroless/base-debian11 AS run

WORKDIR /app

COPY --from=build /src/glauth/bin/glauth64 /app/glauth
COPY --from=build /src/glauth/bin/postgres.so /app/postgres.so
COPY server.cfg /app/server.cfg

USER 1000

ENTRYPOINT ["/app/glauth", "-c", "/app/server.cfg"]
