inherit xcp-ng-rpm

SRCREV = "c725198456cf758e09585d71819b63c895961af0"

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
