inherit xcp-ng-rpm

SRCREV = "26c9c7f9fc326fd24a18b94fd921af0c247e44eb"

DEPENDS += "xen kernel"

RDEPENDS = "xen"

# in EPEL 10.1
EXTRA_UPSTREAM_DEPENDS = " \
https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/l/lcov-2.0-4.fc41.noarch.rpm \
"
