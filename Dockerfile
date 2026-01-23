###
FROM alpine:3.23.2 AS builder
ARG URL=https://releases.ubuntu.com/24.04.3/ubuntu-24.04.3-live-server-amd64.iso
ARG CHECKSUM=sha256:c3514bf0056180d09376462a7a1b4f213c1d6e8ea67fae5c25099c6fd3d8274b

RUN apk update
RUN apk add 7zip
ADD --chown=107:107 --checksum=$CHECKSUM $URL /disk/
RUN cd /tmp && 7z x /disk/*.iso && chown 107:107 -R casper && mv casper /

###
FROM scratch
COPY --from=builder /disk/. /disk/
COPY --from=builder /casper/. /casper/
