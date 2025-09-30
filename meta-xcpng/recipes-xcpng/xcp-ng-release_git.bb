inherit xcp-ng-rpm

SRCREV = "3ad41ad7d6a711b78dba93b8d2618924c7e505ec"

# do not pull xcp-ng-release
PACKAGE_NEEDS_BOOTSTRAP = "1"
DEPENDS = "branding-xcp-ng"
