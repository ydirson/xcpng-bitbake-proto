inherit xcp-ng-rpm

SRCREV = "4c04df5bcf6b15ba497aa55e2fc18ed6cfd4a99e"

RDEPENDS = " \
xcp-ng-release \
kernel \
grub2 \
blktap \
guest-templates-json \
varstored \
vncterm \
xapi \
xo-lite \
xsconsole \
xcp-ng-pv-tools \
xcp-ng-xapi-plugins \
xcp-featured \
"

EXTRA_UPSTREAM_RDEPENDS:aarch64 = " \
    http://www.rpmfind.net/linux/fedora/linux/releases/41/Everything/aarch64/os/Packages/i/iptables-legacy-1.8.10-15.fc41.aarch64.rpm \
    http://www.rpmfind.net/linux/fedora/linux/releases/41/Everything/aarch64/os/Packages/i/iptables-legacy-libs-1.8.10-15.fc41.aarch64.rpm \
    http://www.rpmfind.net/linux/fedora/linux/releases/41/Everything/aarch64/os/Packages/i/iptables-libs-1.8.10-15.fc41.aarch64.rpm \
    http://www.rpmfind.net/linux/fedora/linux/releases/41/Everything/aarch64/os/Packages/i/iptables-services-1.8.10-15.fc41.noarch.rpm \
    http://www.rpmfind.net/linux/fedora/linux/releases/41/Everything/aarch64/os/Packages/i/iptables-utils-1.8.10-15.fc41.aarch64.rpm \
"
