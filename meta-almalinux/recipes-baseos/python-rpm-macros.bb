inherit dnf-bridge

PV = "3.12"
PR = "9.1.el10"

SRC_URI = " \
http://vault.almalinux.org/10.0/AppStream/Source/Packages/python-rpm-macros-3.12-9.1.el10.src.rpm;unpack=0 \
\
http://vault.almalinux.org/10.0/AppStream/x86_64_v2/os/Packages/python-rpm-macros-3.12-9.1.el10.noarch.rpm;unpack=0 \
http://vault.almalinux.org/10.0/AppStream/x86_64_v2/os/Packages/python-srpm-macros-3.12-9.1.el10.noarch.rpm;unpack=0 \
http://vault.almalinux.org/10.0/AppStream/x86_64_v2/os/Packages/python3-rpm-macros-3.12-9.1.el10.noarch.rpm;unpack=0 \
"
