inherit xcp-ng-rpm

SRCREV = "760ae9c7a6a0fff1162aa0bba75b07ad7bb2b46d"
# FIXME why does kabichk with "required file not found"?
XCPNGDEV_BUILD_OPTS = " \
  --rpmbuild-opts='--without kabichk' \
"
