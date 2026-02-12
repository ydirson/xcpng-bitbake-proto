inherit dnf-bridge

PV = "3.30.5"
PR = "3.el10_0"

SRC_URI = " \
http://vault.almalinux.org/10.0/AppStream/Source/Packages/cmake-3.30.5-3.el10_0.src.rpm;unpack=0 \
\
http://vault.almalinux.org/10.0/AppStream/x86_64_v2/os/Packages/cmake-3.30.5-3.el10_0.x86_64_v2.rpm;unpack=0 \
http://vault.almalinux.org/10.0/AppStream/x86_64_v2/os/Packages/cmake-data-3.30.5-3.el10_0.noarch.rpm;unpack=0 \
http://vault.almalinux.org/10.0/AppStream/x86_64_v2/os/Packages/cmake-doc-3.30.5-3.el10_0.noarch.rpm;unpack=0 \
http://vault.almalinux.org/10.0/AppStream/x86_64_v2/os/Packages/cmake-filesystem-3.30.5-3.el10_0.x86_64_v2.rpm;unpack=0 \
http://vault.almalinux.org/10.0/AppStream/x86_64_v2/os/Packages/cmake-gui-3.30.5-3.el10_0.x86_64_v2.rpm;unpack=0 \
http://vault.almalinux.org/10.0/AppStream/x86_64_v2/os/Packages/cmake-rpm-macros-3.30.5-3.el10_0.noarch.rpm;unpack=0 \
"

RDEPENDS = " \
"
