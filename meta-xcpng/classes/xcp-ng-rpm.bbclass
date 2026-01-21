inherit rpm

REPONAME ?= "${PN}"

# FIXME: theoretically it would be BPN rather than PN, but we don't have BPN (yet)
#SRC_URI = "git://github.com/xcp-ng-rpms/${REPONAME};protocol=https;branch=${RPM_BRANCH}"
SRC_URI = "git://github.com/xcp-ng-rpms/${REPONAME};protocol=https;nobranch=1"

# FIXME: this ought to be "${WORKDIR}/git", what's wrong with unpack?
S = "${UNPACKDIR}/git"

# (no) base dependencies for everyone
DEPENDS = ""
