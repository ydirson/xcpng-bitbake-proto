inherit dnf-bridge

PV = "14"
PR = "12.el10"

SRC_URI = " \
http://vault.almalinux.org/10.0/AppStream/Source/Packages/python-rpm-generators-14-12.el10.src.rpm;unpack=0 \
\
http://vault.almalinux.org/10.0/AppStream/x86_64_v2/os/Packages/python3-rpm-generators-14-12.el10.noarch.rpm;unpack=0 \
"

RDEPENDS = "\
python-packaging \
"
