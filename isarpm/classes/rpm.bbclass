DEPENDS ?= ""

# FIXME: xcp-ng-dev commands should be provided by build-env.class

# FIXME we want to share this under DL_DIR, but then only pass the
# requested ones to do_package
BUILDDEPS = "${WORKDIR}/build-deps"

do_fetch_upstream_builddeps() {
    env XCPNG_OCI_RUNNER=podman xcp-ng-dev container builddep "9.0" "${BUILDDEPS}" "${S}" \
        --debug \
        --no-update --disablerepo=xcpng
}
do_fetch_upstream_builddeps[network] = "1"

addtask fetch_upstream_builddeps after do_unpack

# SSTATETASKS += "do_fetch_upstream_builddeps"
# do_package[sstate-plaindirs] = "${WORKDIR}/SRPMS ${WORKDIR}/RPMS"


# produces ${WORKDIR}/SRPMS and ${WORKDIR}/RPMS
do_package() {
    env XCPNG_OCI_RUNNER=podman xcp-ng-dev container build "9.0" "${S}" \
        --debug \
        --no-network --no-update --disablerepo="*" \
        --builddep-dir="${BUILDDEPS}" --enablerepo=builddeps \
        --output-dir="${WORKDIR}"
}
do_package[depends] = "build-env:do_create"

addtask package after do_fetch_upstream_builddeps

SSTATETASKS += "do_package"
do_package[sstate-plaindirs] = "${WORKDIR}/SRPMS ${WORKDIR}/RPMS"

python do_package_setscene () {
    sstate_setscene(d)
}
addtask do_package_setscene
