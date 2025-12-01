inherit xcp-ng-rpm

SRCREV = "f125520e6bd4e75b9f20b34f498201e46db4f32e"

RDEPENDS = " \
xcp-ng-release \
xcp-ng-config \
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
