###
FROM alpine:3.23.3 AS builder
ARG URL=https://releases.ubuntu.com/24.04.3/ubuntu-24.04.3-live-server-amd64.iso
ARG CHECKSUM=sha256:c3514bf0056180d09376462a7a1b4f213c1d6e8ea67fae5c25099c6fd3d8274b
WORKDIR /tmp
RUN apk update
RUN apk add \
      7zip \
      xorriso \
    && echo "Packages installed"
RUN rm -f *.iso
ADD --checksum=$CHECKSUM $URL .
RUN find . -iname '*.iso' -exec 7z e \{\} boot/grub/grub.cfg \;
# Decrease timeout to immedeate boot, and set it to autoinstall
# https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html#user-data
# Ubuntu Autoinstall can load its configuration from cloud-init
RUN sed -i -Ee 's/timeout=[0-9]+/timeout=0/' -e 's/---/autoinstall/' grub.cfg
RUN mkdir -p /disk
# Applying report_el_torito trick from https://help.ubuntu.com/community/LiveCDCustomization
# and add custom grub.cfg
RUN for ISO in *.iso; do \
    xorriso -indev ${ISO} -report_el_torito cmd | xargs xorriso -indev ${ISO} -outdev /disk/autoinstall.iso -map grub.cfg /boot/grub/grub.cfg \
    ; done

###
FROM scratch
COPY --from=builder --chown=107:107 /disk/. /disk/
