inherit xcp-ng-rpm

SRCREV = "9d222a8673f1d6a7e7fb1b726c01627a92329a7a"

DEPENDS += "xcp-python-libs"

RDEPENDS = " \
xcp-python-libs \
biosdevname \
"

# FIXME: newer syslinux seems to work differently, and newer grub is named differently
# FIXME: this is actually required in build-env by install-image-iso
EXTRA_UPSTREAM_RDEPENDS:x86-64-v2 = " \
https://vault.centos.org/7.5.1804/os/x86_64/Packages/syslinux-4.05-13.el7.x86_64.rpm \
https://updates.xcp-ng.org/8/8.3/updates/x86_64/Packages/grub-efi-2.06-4.0.2.1.xcpng8.3.x86_64.rpm \
"

# in EPEL 10.2
EXTRA_UPSTREAM_RDEPENDS:x86-64-v2 += " \
https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/n/ndisc6-1.0.8-2.fc41.x86_64.rpm \
"
