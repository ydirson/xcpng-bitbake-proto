inherit xcp-ng-rpm

SRCREV = "7eb9c8dbfcae5b18f63dac38876ce8043df15a0e"

DEPENDS += "xen"

RDEPENDS = " \
  xen \
  xcp-clipboardd \
"

# in EPEL 10.1
EXTRA_UPSTREAM_DEPENDS = " \
https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/j/jemalloc-devel-5.3.0-7.fc41.x86_64.rpm \
https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/j/jemalloc-5.3.0-7.fc41.x86_64.rpm \
"
