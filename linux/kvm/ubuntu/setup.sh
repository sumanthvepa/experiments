#!/bin/bash

# First verify that your system supports virtualization
# You may have to turn it on in the BIOS if virtualization
# is not enabled.
# For an overview of x86 virtualization, start with the Wikipedia
# page:
# https://en.wikipedia.org/wiki/X86_virtualization

# To verify that your processor supports virtualization, check
# that flags vmx (for Intel processors) or svm (for AMD processors)
# are present in /proc/cpuinfo
# You can use egrep (which allows your multi-character string matches,
# that normal grep does not allow.)
egrep '(vmx|svm)' /proc/cpuinfo

# Instead of accessing /proc/cpuinfo directly, you can also
# get info on virtualization using lscpu.
lscpu | grep -i virtualization
# On Intel machines, this will print 'VT-x' on AMD machines it will
# pint 'AMD-V'

# To use the check in a script use -c option to count the number
# of matches.
CPU_SUPPORT=$(egrep -c '(vmx|svm)' /proc/cpuinfo)

if [[ $CPU_SUPPORT -gt 0 ]]; then
    echo "Machine supports virtualization"
fi

# Install KVM
# The infrastructure to create and run virtual machines on Linux,
# consists of 3 major components:

# KVM
# KVM is the hardware assisted virtualization technology supported
# by Linux. It allows you to create type 2 hypervisors. You can find
# documentation here:
# https://linux-kvm.org/

# QEMU
# It also depends on QEMU, a tool that emulates hardware devices.
# KVM provides a hardware accelerated virtual CPU, and QEMU provides
# all the other virtual devices, needed to create a complete computer.
# There is a project called QEMU-KVM integrates KVM with QEMU, so that
# complete virtual machines with hardware virtualization can be
# created. You can find information about QEMU:
# https://www.qemu.org

# LibVirt
# While KVM and QEMU together allow you to create hardware accelerated
# virtual machines, this process is complicated, since one has to
# manually create all the virtual devices, CPU, memory, disk, networking
# etc... and put them together to create complete virtual machine.
# This is where libvirt comes in, it provides the ability to create
# and manage (start/stop/move etc.) complete virtual machines.
# You can find information about libvirt here:
# https://libvirt.org/index.html

# Then check if KVM is supported
# First install the CPU checker.
apt-get -y install cpu-checker

# Then call kvm-ok see if it reports that kvm is supported
kvm-ok
if [[ $? -eq 0 ]]; then
  echo 'KVM is supported'
fi

# Another way to check for KVM is to ckeck the kvm kernel module
# has been loaded.
zgrep 'KVM_CONFIG' /boot/config-$(uname -r)

# Install all the packages necessary for KVM/QEMU virtualization.
# Here's an explantion of the packages. Note the explanations
# are taken from apt-chche show. To get the explanation for a package
# use apt-cache show <package-name>
# qemu-kvm:
#   This is, a now obsolete package, that provides kvm virtualization
#   integrated with kvm. It has now been subsumed into the the qemu
#   project. Ubuntu, just treats this as an alias for qemu-system-x86
# qemu-system-x86: 
#   This is the quemu project with x86 hardware virtualization using
#   kvm.
# qemu-utils:
#   Utilites and tools to manage disks and other block devices.
# libvirt-daemon-system:
#   This install libvirt configuration to run the libvirt daemon
#   as a configuration service. It pulls in all the other dependencies
#   that make up the libvirt system.
# virtinst:
#   This package contains tools to create virtul machines. Specifically,
#   it contains virt-install a tool to provision operating systems into
#   new virtual machines. virt-clone: A tool to clone inactive VMs.
#   And virt-xml a tool to easily edit libvirt XML using virt-install's
#   command line options.
#  virt-manager:
#    Is a desktop GUI used to manage virtual machines. This is what
#    I normally use to manage VMs.
#  virt-viewer: 
#    Shows the console of a running VM.
#  ovmf:
#    Provides UEFI boot capabilities to VMs. Needed for Windows 11
#    VMs. (amongst others)
#  swtpm:
#    Provides TPM emulation for virtual machines. Needed for Windows
#    11 VMs (amongst others)
#  libosinfo-bin:
#    OSInfo is a database of information about various operating
#    systems and the devices that are optimal for that operating
#    system. For example some OSes may not support some devices
#    or only support some features on those devices. This information
#    is useful for creating fully functioning VMs with installed
#    operating systems, where the VMs virtual devices are well matched
#    to the OS.
#  libvirt-clients:
#    Provides tools that use libvirt, primarily virsh. Virsh is a
#    shell that allows one to create and manage VM using libvirt.
#  bridge-utils:
#    Provides tools to create ethernet bridges on Linux. Ethernet
#    bridges allow a guest VM to be visible on the same network
#    that the host is connected to and accessible via that network.
#    This is critical for setup VMs as servers.
#  tuned:
#    This is a daemon that adaptively tunes system settings for
#    optimal performance. By default, laptops are optimized for
#    desktop performance, not for web server performance. Tuned
#    provides profiles that will dynamically tune the system to
#    run virtual hosts.
apt-get -y install \
  qemu-kvm \
  qemu-system-x86 \
  qemu-utils \
  ovmf \
  swtpm \
  guestfs-tools \
  bridge-utils \
  libosinfo-bin\
  libvirt-daemon-system \
  virtinst \
  virt-manager \
  virt-viewer \
  libvirt-clients \
  tuned
