inherit xcp-ng-rpm

SRCREV = "a4cff47d17119e317002b4153bf96927540b8611"

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
