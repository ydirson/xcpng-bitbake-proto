inherit xcp-ng-rpm

SRCREV = "ab8f45d1170254d5655f08e6444949b5623f1c6c"

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
  xengt-userspace \
"

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
  https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/40/Everything/x86_64/Packages/p/python3-opentelemetry-exporter-zipkin-1.25.0-2.fc40.noarch.rpm \
  https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/40/Everything/x86_64/Packages/p/python3-opentelemetry-exporter-zipkin-proto-http-1.25.0-2.fc40.noarch.rpm \
  https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/40/Everything/x86_64/Packages/p/python3-opentelemetry-api-1.25.0-2.fc40.noarch.rpm \
  https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/40/Everything/x86_64/Packages/p/python3-opentelemetry-sdk-1.25.0-2.fc40.noarch.rpm \
  https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/40/Everything/x86_64/Packages/p/python3-opentelemetry-semantic-conventions-0.46~b0-2.fc40.noarch.rpm \
  https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/40/Everything/x86_64/Packages/p/python3-zipp-3.17.0-4.fc40.noarch.rpm \
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
"
