inherit xcp-ng-rpm

SRCREV = "bc86361ec85346087c7adad6e6fa526938fcd106"

DEPENDS += "ocaml ocaml-findlib libempserver"

EXTRA_UPSTREAM_DEPENDS = " \
http://www.rpmfind.net/linux/fedora/linux/releases/41/Everything/x86_64/os/Packages/d/dev86-0.16.21-27.fc41.x86_64.rpm \
http://www.rpmfind.net/linux/fedora/linux/releases/41/Everything/x86_64/os/Packages/f/figlet-2.2.5-29.20151018gita565ae1.fc41.x86_64.rpm \
"
