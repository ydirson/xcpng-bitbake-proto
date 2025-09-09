# Recipe to create a build-env (and ultimately build packages from it).
# This is an XCP-ng *bootstrap* podman container to make sure we do not
# rely on any already-built XCP-ng package, just AlmaLinux ones.
#
# TODO: should actually be split between some generic support one one
# side, which the rpm class can rely on, and specific implementation
# for xcp-ng-build-env on another side.

SRC_URI = "git://github.com/xcp-ng/xcp-ng-build-env;protocol=https;branch=ydi/9"
SRCREV = "b7693f9cdb52d5d8603a117587c19eb566b4a7cf"

# FIXME: this ought to be "${WORKDIR}/git", what's wrong with unpack?
S = "${UNPACKDIR}/git"

# FIXME this uses installed version not fetched one
do_create() {
    # env XCPNG_OCI_RUNNER=podman ${S}/src/xcp_ng_dev/build.sh --bootstrap 9.0
    env XCPNG_OCI_RUNNER=podman xcp-ng-dev-env-create --bootstrap 9.0
}
# FIXME: temporary until we separately fetch the required RPMs
do_create[network] = "1"

addtask create after do_unpack
