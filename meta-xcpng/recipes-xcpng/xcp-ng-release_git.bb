inherit xcp-ng-rpm

SRCREV = "10f06544571575fd70fa025f2094e4ca71568acc"

# do not pull xcp-ng-release
PACKAGE_NEEDS_BOOTSTRAP = "1"
DEPENDS = "branding-xcp-ng"
