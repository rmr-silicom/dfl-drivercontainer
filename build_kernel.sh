#!/bin/bash

export KERNEL=$(basename /usr/src/kernels/${1}*)
export KERNELDIR=/lib/modules/$KERNEL/build
export KMODVER=${2}

if [ ! -e $KERNELDIR ] ; then
    mkdir -p /lib/modules/$KERNEL
    ln -s /usr/src/kernels/$KERNEL
    /lib/modules/$KERNEL/build;
fi

rm -rf /lib/modules/${KVER}/kernel
make -C linux-dfl-backport "EXTRA_CFLAGS=-DKMODVER=\\\"${KMODVER}\\\"" -j4
make -C linux-dfl-backport install -j4
depmod -a ${KERNEL}
