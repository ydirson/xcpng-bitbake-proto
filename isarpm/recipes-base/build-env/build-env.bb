# Recipe to create a build-env (and ultimately build packages from it).
# This is an XCP-ng *bootstrap* podman container to make sure we do not
# rely on any already-built XCP-ng package, just AlmaLinux ones.
#
# TODO: should actually be split between some generic support one one
# side, which the rpm class can rely on, and specific implementation
# for xcp-ng-build-env on another side.

SRC_URI = "git://github.com/xcp-ng/xcp-ng-build-env;protocol=https;branch=ydi/9"
SRCREV = "94beaba634fbfa80756cc5e7d5a72132f71fe838"

# FIXME: this ought to be "${WORKDIR}/git", what's wrong with unpack?
S = "${UNPACKDIR}/git"

do_create() {
    env XCPNG_OCI_RUNNER=podman ${S}/container/build.sh --bootstrap 9.0
}
# FIXME: temporary until we separately fetch the required RPMs
do_create[network] = "1"

addtask create after do_unpack


# default target
do_build() {
}
addtask do_build after do_create
