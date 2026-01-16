inherit dnf-bridge

PV = "24.2"
PR = "2.el10"

SRC_URI = " \
http://vault.almalinux.org/10.0/BaseOS/Source/Packages/python-packaging-24.2-2.el10.src.rpm;unpack=0 \
\
http://vault.almalinux.org/10.0/BaseOS/x86_64_v2/os/Packages/python3-packaging-24.2-2.el10.noarch.rpm;unpack=0 \
"
