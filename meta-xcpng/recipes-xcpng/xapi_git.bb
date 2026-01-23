inherit xcp-ng-rpm

# FIXME: update EXTRA_UPSTREAM_RDEPENDS:append:x86_64 when we bump this
SRCREV = "46438db3346db96b45a789d2b5d728c7f2fc66d5"
SRCREV:aarch64 = "59073c0986105fae3f348c8ba8293b34c167d783"

# add "noshared" to let git-describe work in the container, for the "-dirty" workaround
BB_GIT_NOSHARED = "1"

DEPENDS += " \
  ocaml \
  xen \
  xs-opam-repo \
  blktap \
  sm \
"

# xapi-core
RDEPENDS += " \
  sm \
  xcp-python-libs \
  vmss \
  xcp-ng-release \
"
# FIXME cannot include without creating a loop.  But cannot do_deploy xapi-core without it.
#  xcp-featured \
#
# obsolete?
#  kpatch \
#

# xenopsd-xc
RDEPENDS += " \
  xcp-ng-generic-lib \
  emu-manager \
  qemu \
  xcp-clipboardd \
"
# FIXME: temporary disabled in ARM while we bootstrap
RDEPENDS:remove:aarch64 = "qemu"

# rrdd-plugins
RDEPENDS += " \
  xen \
"

# *-devel
RDEPENDS += " \
  xs-opam-repo \
"

# https://download.fedoraproject.org/pub/fedora/linux/releases/
# FIXME? lacks a way to declare missing dep of redhat-lsb on initscripts
EXTRA_UPSTREAM_RDEPENDS = " \
  https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/40/Everything/x86_64/os/Packages/p/python3-urlgrabber-4.1.0-16.fc40.noarch.rpm \
  https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/40/Everything/x86_64/os/Packages/p/python3-importlib-metadata-6.9.0-3.fc40.noarch.rpm \
  https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/40/Everything/x86_64/Packages/p/python3-opentelemetry-exporter-zipkin-1.25.0-2.fc40.noarch.rpm \
  https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/40/Everything/x86_64/Packages/p/python3-opentelemetry-exporter-zipkin-json-1.25.0-2.fc40.noarch.rpm \
  https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/40/Everything/x86_64/Packages/p/python3-opentelemetry-exporter-zipkin-proto-http-1.25.0-2.fc40.noarch.rpm \
  https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/40/Everything/x86_64/Packages/p/python3-opentelemetry-api-1.25.0-2.fc40.noarch.rpm \
  https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/40/Everything/x86_64/Packages/p/python3-opentelemetry-sdk-1.25.0-2.fc40.noarch.rpm \
  https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/40/Everything/x86_64/Packages/p/python3-opentelemetry-semantic-conventions-0.46~b0-2.fc40.noarch.rpm \
  https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/40/Everything/x86_64/Packages/p/python3-zipp-3.17.0-4.fc40.noarch.rpm \
"

EXTRA_UPSTREAM_RDEPENDS:append:x86-64-v2 = " \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/d/dhcp-client-4.4.3-14.P1.fc41.x86_64.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/d/dhcp-common-4.4.3-14.P1.fc41.noarch.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/n/nbd-3.25-5.fc41.x86_64.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/s/ssmtp-2.64-37.fc41.x86_64.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/r/redhat-lsb-core-5.0-0.11.20231006git8d00acdc.fc41.x86_64.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/r/redhat-lsb-5.0-0.11.20231006git8d00acdc.fc41.x86_64.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/s/spax-1.6-15.fc41.x86_64.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/o/openvswitch-3.4.0-2.fc41.x86_64.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/l/libcgroup-tools-3.0-6.fc41.x86_64.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/l/libcgroup-3.0-6.fc41.x86_64.rpm \
  \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/i/iptables-legacy-1.8.10-15.fc41.x86_64.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/i/iptables-legacy-libs-1.8.10-15.fc41.x86_64.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/i/iptables-libs-1.8.10-15.fc41.x86_64.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/i/iptables-services-1.8.10-15.fc41.noarch.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/i/iptables-utils-1.8.10-15.fc41.x86_64.rpm \
"

# in EPEL 10.1
EXTRA_UPSTREAM_RDEPENDS:append:x86-64-v2 = " \
https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/j/jemalloc-5.3.0-7.fc41.x86_64.rpm \
"

EXTRA_UPSTREAM_RDEPENDS:append:aarch64 = " \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/aarch64/os/Packages/d/dhcp-client-4.4.3-14.P1.fc41.aarch64.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/aarch64/os/Packages/d/dhcp-common-4.4.3-14.P1.fc41.noarch.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/aarch64/os/Packages/n/nbd-3.25-5.fc41.aarch64.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/aarch64/os/Packages/s/ssmtp-2.64-37.fc41.aarch64.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/aarch64/os/Packages/r/redhat-lsb-core-5.0-0.11.20231006git8d00acdc.fc41.aarch64.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/aarch64/os/Packages/r/redhat-lsb-5.0-0.11.20231006git8d00acdc.fc41.aarch64.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/aarch64/os/Packages/s/spax-1.6-15.fc41.aarch64.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/aarch64/os/Packages/o/openvswitch-3.4.0-2.fc41.aarch64.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/aarch64/os/Packages/l/libcgroup-tools-3.0-6.fc41.aarch64.rpm \
  https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/aarch64/os/Packages/l/libcgroup-3.0-6.fc41.aarch64.rpm \
\
  http://www.rpmfind.net/linux/fedora/linux/releases/41/Everything/aarch64/os/Packages/i/iptables-legacy-1.8.10-15.fc41.aarch64.rpm \
  http://www.rpmfind.net/linux/fedora/linux/releases/41/Everything/aarch64/os/Packages/i/iptables-legacy-libs-1.8.10-15.fc41.aarch64.rpm \
  http://www.rpmfind.net/linux/fedora/linux/releases/41/Everything/aarch64/os/Packages/i/iptables-libs-1.8.10-15.fc41.aarch64.rpm \
  http://www.rpmfind.net/linux/fedora/linux/releases/41/Everything/aarch64/os/Packages/i/iptables-services-1.8.10-15.fc41.noarch.rpm \
  http://www.rpmfind.net/linux/fedora/linux/releases/41/Everything/aarch64/os/Packages/i/iptables-utils-1.8.10-15.fc41.aarch64.rpm \
"
