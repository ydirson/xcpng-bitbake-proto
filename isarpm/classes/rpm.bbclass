DEPENDS ?= ""

# produces ${WORKDIR}/SRPMS and ${WORKDIR}/RPMS
do_package() {
    # FIXME: command should be provided by build-env.class
    env XCPNG_OCI_RUNNER=podman xcp-ng-dev container build 9.0 "${S}" \
        --no-update --disablerepo=xcpng \
        --platform=linux/amd64 \
        --output-dir=${WORKDIR}
}
do_package[depends] = "build-env:do_create"
# FIXME: disabling network access through a user namespace currently
# prevents podman from starting, bitbake likely needs to learn.  See
# https://github.com/containers/podman/issues/15238
do_package[network] = "1"

addtask package after do_unpack

SSTATETASKS += "do_package"
do_package[sstate-plaindirs] = "${WORKDIR}/SRPMS ${WORKDIR}/RPMS"

python do_package_setscene () {
    sstate_setscene(d)
}
addtask do_package_setscene
