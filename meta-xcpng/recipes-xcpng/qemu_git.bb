inherit xcp-ng-rpm

SRCREV = "42501508cb3fce9f7eeea9db278825376a4a5b5e"

DEPENDS += "xen"

RDEPENDS = " \
  xen \
  xcp-clipboardd \
  xengt-userspace \
"
