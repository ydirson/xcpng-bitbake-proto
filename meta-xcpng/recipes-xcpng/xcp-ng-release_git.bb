inherit xcp-ng-rpm

SRCREV = "1c55f45b5aa01cd2686c21b2cadf4905205c95f1"

# do not pull xcp-ng-release
PACKAGE_NEEDS_BOOTSTRAP = "1"
DEPENDS = "branding-xcp-ng"
