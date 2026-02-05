inherit dnf-bridge

# dnf repoquery --source python3-devel
# PN = "python3.12"

PV = "3.12.9"
PR = "2.el10_0.3"

# FIXME: actually only those for python3-devel
RDEPENDS = " \
python-rpm-macros \
python-rpm-generators \
"

# FIXME: RPMs should be in a separate directory in download dir

# FIXME: needs an Alma container to run those commands (or better, a specific config)

# dnf repoquery --quiet --disablerepo=* --enablerepo=*-source python3.12-3.12.9-2.el10_0.3.src --location | sed 's/$/;unpack=0 \\/'
# dnf repoquery --quiet --qf '%{name}-%{evr} %{sourcerpm}' | grep ' python3.12-3.12.9-2.el10_0.3.src.rpm' | cut -d' ' -f1 | xargs dnf repoquery --quiet --location | sed 's/$/;unpack=0 \\/'

SRC_URI = " \
http://vault.almalinux.org/10.0/BaseOS/Source/Packages/python3.12-3.12.9-2.el10_0.3.src.rpm;unpack=0 \
\
http://vault.almalinux.org/10.0/AppStream/x86_64_v2/os/Packages/python-unversioned-command-3.12.9-2.el10_0.3.noarch.rpm;unpack=0 \
http://vault.almalinux.org/10.0/AppStream/x86_64_v2/os/Packages/python3-devel-3.12.9-2.el10_0.3.x86_64_v2.rpm;unpack=0 \
http://vault.almalinux.org/10.0/AppStream/x86_64_v2/os/Packages/python3-tkinter-3.12.9-2.el10_0.3.x86_64_v2.rpm;unpack=0 \
http://vault.almalinux.org/10.0/BaseOS/x86_64_v2/os/Packages/python3-3.12.9-2.el10_0.3.x86_64_v2.rpm;unpack=0 \
http://vault.almalinux.org/10.0/BaseOS/x86_64_v2/os/Packages/python3-libs-3.12.9-2.el10_0.3.x86_64_v2.rpm;unpack=0 \
http://vault.almalinux.org/10.0/CRB/x86_64_v2/os/Packages/python3-debug-3.12.9-2.el10_0.3.x86_64_v2.rpm;unpack=0 \
http://vault.almalinux.org/10.0/CRB/x86_64_v2/os/Packages/python3-idle-3.12.9-2.el10_0.3.x86_64_v2.rpm;unpack=0 \
http://vault.almalinux.org/10.0/CRB/x86_64_v2/os/Packages/python3-test-3.12.9-2.el10_0.3.x86_64_v2.rpm;unpack=0 \
"

# FIXME checksums
