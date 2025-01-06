#!/bin/bash

# Some resources on setting up KVM:
# YouTube:
# Short but Ubuntu Specific: https://www.youtube.com/watch?v=qCUmf5gyOYY
# More comprehensive, but focuses on Fedora. But does not use netplan
# to configure bridging.
# https://www.youtube.com/watch?v=LHJhFW7_8EI
# Instructions from Server World (similar to the first Ubuntu
# specific instructions)
# https://www.server-world.info/en/note?os=Ubuntu_24.04&p=kvm



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

# Enable and start the libvirtd
# Libvirtd is a daemon that handles management tasks for virtual machines.
# This deaemon handles tasks such as starting and stoppiing virtual machines
# migrating guests across hosts, configuring and manipulating networking
# and managing storage for guests.
# TODO: Figure out how libvirtd commiunicates with tools like virt-install
# to do its work.
# Note that for now we will be installing the monolithic libvirtdaemon
# This monolithic daemon is being phased out for a collection of modular
# daemon
systemctl enable --now libvirtd
systemctl start libvirtd

# VirtIOWin is an ISO that contains windows drivers
# for a windows guest running on KVM. They need to be
# installed within the guest windows OS. The iso
# needs to be mounted as a CD in the guest and the
# drivers can be installed.

# Add users that you want to the groups kvm and libvirt
# This allows you to run virtual machines as normal user
groups svepa | grep kvm
if [[ $? -ne 0 ]]; then
  echo "Adding user svepa to group kvm"
  usermod -aG kvm svepa
else
  echo "User svepa is already a member of group kvm"
fi

groups svepa | grep libvirt
if [[ $? -ne 0 ]]; then
  echo "Adding user svepa to group libvirt"
  usermod -aG libvirt svepa
else
  echo "User svepa is already a member of group libvirt"
fi


# Check that your virtualization is properly installed
virt-host-validate qemu

# All entries should say 'PASS' except for possibly an
# entry on Intel machines for checking for secure guest
# support (that is an AMD only feature)


# For now don't install tuned. It seems to cause
# problems with networking

# The next step is to enable and start tuned
# tuned dynamically optimizes a computer's performance
# for a given profile.
# systemctl enable --now tuned
# systemctl start tuned
# Set the profile to the virtual-host which is a profile
# that is optimal for running VMs.
# You can see the current profile using tuned-adm
# note that tuned must be running for tuned-adm to work
# tuned-adm active
# You can get a list of available profiles with
# tuned-adm


# The next important thing to setup on the physical host is
# networking.

# Ubuntu encourages the use of netplan to setup networking.
# Netplan is a configuration tool that runs at boot time,
# to generate configuration files for either networkd or
# NetworkManager, which then manage the actual networking.
# Netplan comes pre-installed with the default install of
# Ubuntu. So there is no necessity to install it.

# The primary drawback is that Fedora, AlmaLinux and RHEL
# based systems don't use netplan. You need a different
# way to configure bridging on those systems.

# See 60-netplan.yaml for details on how to configure
# netplan
cp 60-network.yaml /etc/netplan
chown root:root /etc/netplan/60-network.yaml
chmod go-rwx /etc/netplan/60-network.yaml
netplan apply

# It's probably a good idea to reboot the machine
# at this point
# TODO: Implement a continue after reboot system

# Next add the bridge as a named network for VMs
# connect to. This isn't strictly speaking
# required, but makes life easy.

# First list the networks that libvirtd is aware of, and that are active
virsh net-list

# using the --all option also show networks that libvirtd is aware of
# but are not active
virsh net-list --all

# If you want more information about a specific network
# use:
# virsh net-info <networkname>
# E.g. to get info about the default network:
# virsh net-info default


# Now define a bridge network that uses the bridge interface br0
virsh net-define ./kvm-bridge-network.xml

# The bridge is not active yet. If you do virsh net-list it won't
# show up. But if you do virsh net-list --all it will show up
# as inactive.

# Start the bridge
virsh net-start bridge0  # The name 'bridge0' is taken from the name tag
                         # in the  XML file

# To ensure that the bridge0 network is always available across reboots
# it needs to be auto started
# Set the bridge0 network to auto start
virsh  net-autostart bridge0


# On Ubuntu even user created VMs belong to the system domain.
# But just check. the URI printed by the command below must be
# qemu:///system  and NOT quemu:///session.  Note the 3 slashes.
virsh uri  # should print 'qemu:///system'
