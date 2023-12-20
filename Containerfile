#Build from base, simpley because it's the smallest image
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-kinoite-main}"
ARG BASE_IMAGE="quay.io/fedora/${SOURCE_IMAGE}"
ARG COREOS_VERSION="${COREOS_VERSION:-39}"

FROM ${BASE_IMAGE}:${COREOS_VERSION} AS builder
ARG COREOS_VERSION="${COREOS_VERSION:-39}"

COPY build*.sh /tmp
COPY certs /tmp/certs

RUN /tmp/build-prep.sh

RUN ZFS_MINOR_VERSION=2.2 /tmp/build-kmod-zfs.sh

RUN for RPM in $(find /var/cache/akmods/ -type f -name \*.rpm); do \
        cp "${RPM}" /var/cache/rpms/kmods/; \
    done

RUN find /var/cache/rpms

FROM scratch

COPY --from=builder /var/cache/rpms /rpms
