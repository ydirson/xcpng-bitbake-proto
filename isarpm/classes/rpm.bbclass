DEPENDS ?= ""

DEPLOY_DIR_ISARPM = "${DEPLOY_DIR}/rpms"
RECIPE_DEPLOY_DIR = "${DEPLOY_DIR_ISARPM}/${PN}"

# FIXME: xcp-ng-dev commands should be provided by build-env.class


BUILDDEPS_MANAGED_REPONAME = "bdeps-managed"
BUILDDEPS_MANAGED = "${WORKDIR}/${BUILDDEPS_MANAGED_REPONAME}"

do_prepare_managed_builddeps() {
    rm -rf "${BUILDDEPS_MANAGED}"
    mkdir -p "${BUILDDEPS_MANAGED}"
    for dep in ${DEPENDS}; do
        cp -a "${DEPLOY_DIR_ISARPM}/${dep}/RPMS" "${BUILDDEPS_MANAGED}/${dep}"
    done
    #createrepo_c --compatibility "${BUILDDEPS_MANAGED}"
}
addtask do_prepare_managed_builddeps after do_unpack
do_prepare_managed_builddeps[deptask] = "do_deploy"
do_prepare_managed_builddeps[vardepsexclude] += "PACKAGE_EXTRA_ARCHS BB_TASKDEPDATA"

BUILDDEPS_UPSTREAM_REPONAME = "bdeps-upstream"
# FIXME we want to share this under DL_DIR, but then only pass the
# requested ones to do_package
BUILDDEPS_UPSTREAM = "${WORKDIR}/${BUILDDEPS_UPSTREAM_REPONAME}"

# FIXME: this makes a copy of managed (and extra) builddeps
do_fetch_upstream_builddeps() {
    env XCPNG_OCI_RUNNER=podman xcp-ng-dev container builddep "9.0" "${BUILDDEPS_UPSTREAM}" "${S}" \
        --debug \
        --local-repo="${BUILDDEPS_MANAGED}" --enablerepo="${BUILDDEPS_MANAGED_REPONAME}" \
        --no-update --disablerepo=xcpng        
}
do_fetch_upstream_builddeps[network] = "1"
do_fetch_upstream_builddeps[depends] = "build-env:do_create"

addtask do_fetch_upstream_builddeps after do_prepare_managed_builddeps

# SSTATETASKS += "do_fetch_upstream_builddeps"
# do_package[sstate-plaindirs] = "${WORKDIR}/SRPMS ${WORKDIR}/RPMS"


# produces ${WORKDIR}/SRPMS and ${WORKDIR}/RPMS
do_package() {
    env XCPNG_OCI_RUNNER=podman xcp-ng-dev container build "9.0" "${S}" \
        --debug \
        --no-network --no-update --disablerepo="*" \
        --local-repo="${BUILDDEPS_MANAGED}" --enablerepo="${BUILDDEPS_MANAGED_REPONAME}" \
        --local-repo="${BUILDDEPS_UPSTREAM}" --enablerepo="${BUILDDEPS_UPSTREAM_REPONAME}" \
        --output-dir="${WORKDIR}"
}
do_package[depends] = "build-env:do_create"

addtask do_package after do_fetch_upstream_builddeps

SSTATETASKS += "do_package"
do_package[sstate-plaindirs] = "${WORKDIR}/SRPMS ${WORKDIR}/RPMS"

python do_package_setscene () {
    sstate_setscene(d)
}
addtask do_package_setscene


do_deploy() {
    rm -rf "${RECIPE_DEPLOY_DIR}"
    mkdir -p "${RECIPE_DEPLOY_DIR}"
    cp -a "${WORKDIR}/SRPMS" "${WORKDIR}/RPMS" "${RECIPE_DEPLOY_DIR}/"
}
addtask do_deploy after do_package


# default target, FIXME should do more stuff
do_build() {
}
addtask do_build after do_deploy
