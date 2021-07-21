ARG BUILD_IMAGE_BASE
FROM ${BUILD_IMAGE_BASE}

ARG KMODVER
ARG KVER

RUN mkdir -p /etc/pki/entitlement
COPY pki.key /etc/pki/entitlement/entitlement.pem
COPY pki.key /etc/pki/entitlement/entitlement-key.pem

WORKDIR /root

RUN yum install -y git-core gcc elfutils-libelf-devel make kmod

RUN git clone --branch n5010/fpga-ofs-dev-5.10-lts https://github.com/OPAE/linux-dfl-backport.git && \
    cd linux-dfl-backport && \
    git checkout ${KMODVER} && \
    grep -l -v -r MODULE_VERSION drivers/ | xargs sed -i '/^MODULE_LICENSE/ s/$/\nMODULE_VERSION(KMODVER);/' && \
    cd -

RUN echo "export KERNEL=$(rpm -qa kernel-devel --queryformat \"%{VERSION}-%{RPMTAG_RELEASE}.%{ARCH}\")" > /root/env && \
    echo "export KERNELDIR=/lib/modules/\$KERNEL/build" >> /root/env && \
    echo "export KMODVER=${KMODVER}" >> /root/env

RUN source /root/env && \
    bash -c "if [ ! -e $KERNELDIR ] ; then mkdir -p /lib/modules/\$KERNEL ; ln -s /usr/src/kernels/\$KERNEL /lib/modules/\$KERNEL/build; fi" \
    rm -rf /lib/modules/${KVER}/kernel && \
    make -C linux-dfl-backport "EXTRA_CFLAGS=-DKMODVER=\\\"${KMODVER}\\\"" -j4 && \
    make -C linux-dfl-backport install -j4 && \
    depmod -a ${KVER}


FROM registry.access.redhat.com/ubi8/ubi-minimal
RUN microdnf install kmod
RUN mkdir -p /lib/modules/${KVER}
COPY --from=0 /lib/modules/${KVER} /lib/modules/${KVER}
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
