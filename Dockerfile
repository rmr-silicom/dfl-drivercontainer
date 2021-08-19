ARG BUILD_IMAGE_BASE
FROM ${BUILD_IMAGE_BASE}

ARG KMODVER
ARG KVER

RUN mkdir -p /etc/pki/entitlement
COPY pki.key /etc/pki/entitlement/entitlement.pem
COPY pki.key /etc/pki/entitlement/entitlement-key.pem
COPY build_kernel.sh /
WORKDIR /root

RUN yum install -y git-core gcc elfutils-libelf-devel make kmod

RUN git clone --branch n5010/fpga-ofs-dev-5.10-lts https://github.com/OPAE/linux-dfl-backport.git && \
    cd linux-dfl-backport && \
    git checkout ${KMODVER} && \
    grep -l -v -r MODULE_VERSION drivers/ | xargs sed -i '/^MODULE_LICENSE/ s/$/\nMODULE_VERSION(KMODVER);/' && \
    cd -

RUN /build_kernel.sh ${KVER} ${KMODVER}

FROM registry.access.redhat.com/ubi8/ubi-minimal
RUN microdnf install kmod
RUN mkdir -p /lib/modules/${KVER}
COPY --from=0 /lib/modules/${KVER} /lib/modules/${KVER}
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
