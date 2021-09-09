FROM golang:1.17 as builder
WORKDIR /app
COPY . .
RUN if [ `uname -m` = "aarch64" ] ; then \
        GO111MODULE=on GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o ./fluxcloud ./cmd/;  \
    else \
        GO111MODULE=on GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ./fluxcloud ./cmd/;  \
    fi

FROM alpine:3.13.6
RUN apk update && apk add ca-certificates

FROM gcr.io/distroless/static@sha256:48e0d165f07d499c02732d924e84efbc73df8021b12c24940e18a9306589430e
COPY --from=0 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

WORKDIR /app
COPY --from=builder /app/fluxcloud .
EXPOSE 3031
ENTRYPOINT ["/app/fluxcloud"]
