inherit xcp-ng-rpm

SRCREV = "c24578b492c3e6463885cb069d2c6bf2dce1e804"

# do not pull xcp-ng-release
PACKAGE_NEEDS_BOOTSTRAP = "1"
DEPENDS = "branding-xcp-ng"
