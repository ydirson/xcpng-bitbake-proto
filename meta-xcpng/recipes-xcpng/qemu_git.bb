inherit xcp-ng-rpm

SRCREV = "42501508cb3fce9f7eeea9db278825376a4a5b5e"

DEPENDS += "xen"

RDEPENDS = " \
  xen \
  xcp-clipboardd \
  xengt-userspace \
"

# in EPEL 10.1
EXTRA_UPSTREAM_DEPENDS = " \
https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/j/jemalloc-devel-5.3.0-7.fc41.x86_64.rpm \
https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/j/jemalloc-5.3.0-7.fc41.x86_64.rpm \
"
