#!/bin/bash

set -e
set -u

if [ -e ../../configure.sh ]; then
    source ../../configure.sh
elif [ -e ../configure.sh ]; then
    source ../configure.sh
elif [ -e ./configure.sh ]; then
    source ./configure.sh
else
    echo "Error: Could not find 'configure.sh'!"
    exit 1
fi

if check_number $1; then
    echo "Usage: run.armel.sh <image ID>"
    exit 1
fi
IID=${1}

WORK_DIR=`get_vm ${IID}`
IMAGE=`get_fs ${IID}`
KERNEL=`get_kernel "armel"`

QEMU_AUDIO_DRV=none qemu-system-arm -m 256 -M virt -kernel ${KERNEL} -drive if=none,file=${IMAGE},format=raw,id=rootfs -device virtio-blk-device,drive=rootfs -append "firmadyne.syscall=1 root=/dev/vda1 console=ttyS0 nandsim.parts=64,64,64,64,64,64,64,64,64,64 rdinit=/firmadyne/preInit.sh rw debug ignore_loglevel print-fatal-signals=1 user_debug=31" -serial file:${WORK_DIR}/qemu.initial.serial.log -serial unix:/tmp/qemu.${IID}.S1,server,nowait -monitor unix:/tmp/qemu.${IID},server,nowait -display none -device virtio-net-device,netdev=net1 -netdev socket,listen=:2000,id=net1 -device virtio-net-device,netdev=net2 -netdev socket,listen=:2001,id=net2 -device virtio-net-device,netdev=net3 -netdev socket,listen=:2002,id=net3 -device virtio-net-device,netdev=net4 -netdev socket,listen=:2003,id=net4
