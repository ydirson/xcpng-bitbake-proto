inherit dnf-bridge

PV = "0.18"
PR = "3.el10"

SRC_URI = " \
http://vault.almalinux.org/10.0/BaseOS/Source/Packages/json-c-0.18-3.el10.src.rpm;unpack=0 \
\
http://vault.almalinux.org/10.0/AppStream/x86_64_v2/os/Packages/json-c-devel-0.18-3.el10.x86_64_v2.rpm;unpack=0 \
http://vault.almalinux.org/10.0/BaseOS/x86_64_v2/os/Packages/json-c-0.18-3.el10.x86_64_v2.rpm;unpack=0 \
http://vault.almalinux.org/10.0/CRB/x86_64_v2/os/Packages/json-c-doc-0.18-3.el10.x86_64_v2.rpm;unpack=0 \
"

RDEPENDS = " \
cmake \
"
