inherit xcp-ng-rpm

SRCREV = "c8bc1e7ae1adbdfacec85632239cbab1820fa6b9"

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
