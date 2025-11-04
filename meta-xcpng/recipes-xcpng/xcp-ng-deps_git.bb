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

# pulls qemu, not yet on aarch64
RDEPENDS:remove:aarch64 = "vncterm"
