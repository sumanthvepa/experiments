#!/bin/bash

# This prints the types and variants of operating systems that kvm is
# aware of
# osinfo-query os

# Check if almalinux9 is available as a variant.
os_variant=$(osinfo-query os | grep 'almalinux9' | gawk '{print $1;}')
if [[ $os_variant != 'almalinux9' ]]; then
  echo 'almalinux9 NOT available as an OS variant'
  exit 1
fi

# TODO: If almalinux is not available, use the latest version of redhat
# as the osvariant

# This creates a virtual machine with the following parameters:
# --name='pitts'  This is the name of the VM used to start/stop the VM in virsh
# --vcpus=1 Tells KVM to allocate 1 virtual CPU core to the VM
# --ram=2048  Tells KVM to allocate 2GiB of RAM (2048MiB)
# --disk size=20 Tells KVM to allocate disk of 20GB
# --network network:bridge0  Tells KVM/QEMU to use the bridge0 network
# --graphics none Tells KVM/QEMU that no graphics are required
# --os-variant='almalinux9' Tells KVM to optimize the device profile
#     for almalinux9
# --location ./os/AlmaLinux-9.5-x86_64-minimal.iso: Tells KVM to mount
#      the iso at the specified location as CD/DVD rom disk to boot from
# --extra-args Tells KVM to create two consoles one is an ordinary tty and
#              the other is a serial port. These are need if you need
#              access to the console directly (and you don't have ssh access)
#  You can access the console after the machine has been created as follows:
#  virsh console pitts
#  This gives you a login console. You can exit the console using Crtl-]
virt-install --name='pitts' --vcpus=1 --ram=2048 --disk size=20 --network network:bridge0 --graphics none \
  --os-variant='almalinux9' --location=./os/AlmaLinux-9.5-x86_64-minimal.iso \
  --extra-args='console=tty0 console=ttyS0,115200'

# Connect to a console if needed:
# virsh console pitts
