DEPENDS ?= ""

# produces ${WORKDIR}/SRPMS and ${WORKDIR}/RPMS
do_package() {
    xcp-ng-dev container build "${S}" 9.0 \
        --no-update --disablerepo=xcpng \
        --rm --platform=linux/amd64 \
        --output-dir=${WORKDIR}
}
# FIXME: disabling network access through a user namespace currently
# prevents podman from starting, bitbake likely needs to learn.  See
# https://github.com/containers/podman/issues/15238
do_package[network] = "1"

addtask package after do_unpack
