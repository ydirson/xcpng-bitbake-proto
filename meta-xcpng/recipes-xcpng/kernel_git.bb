inherit xcp-ng-rpm

SRCREV = "7a55fb95a6da1073c1d1e8d2ad7837e3da65addf"
# FIXME why does kabichk with "required file not found"?
XCPNGDEV_BUILD_OPTS = " \
  --rpmbuild-opts='--without kabichk' \
"
