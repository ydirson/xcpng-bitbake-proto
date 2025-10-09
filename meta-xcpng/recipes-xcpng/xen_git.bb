inherit xcp-ng-rpm

SRCREV = "6cc1767aeea19d740d98a44bcdac7ae2a4e27120"

DEPENDS += "ocaml ocaml-findlib libempserver"

EXTRA_UPSTREAM_DEPENDS = " \
http://www.rpmfind.net/linux/fedora/linux/releases/41/Everything/x86_64/os/Packages/d/dev86-0.16.21-27.fc41.x86_64.rpm \
http://www.rpmfind.net/linux/fedora/linux/releases/41/Everything/x86_64/os/Packages/f/figlet-2.2.5-29.20151018gita565ae1.fc41.x86_64.rpm \
"

EXTRA_UPSTREAM_DEPENDS:aarch64 = " \
http://www.rpmfind.net/linux/fedora/linux/releases/41/Everything/aarch64/os/Packages/f/figlet-2.2.5-29.20151018gita565ae1.fc41.aarch64.rpm \
"

RDEPENDS = " \
libempserver \
ocaml \
"

RDEPENDS:append:x86_64_v2 = " \
edk2 ipxe \
"

EXTRA_UPSTREAM_RDEPENDS = " \
http://www.rpmfind.net/linux/fedora/linux/releases/41/Everything/x86_64/os/Packages/f/figlet-2.2.5-29.20151018gita565ae1.fc41.x86_64.rpm \
"

EXTRA_UPSTREAM_RDEPENDS:aarch64 = " \
http://www.rpmfind.net/linux/fedora/linux/releases/41/Everything/aarch64/os/Packages/f/figlet-2.2.5-29.20151018gita565ae1.fc41.aarch64.rpm \
"
