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


## FIXME: hack to rely on RPMs from Fedora etc until they reach EPEL10
# URLs of RPMs not yet in our official upstream
EXTRA_UPSTREAM = ""

BUILDDEPS_EXTRA_REPONAME = "bdeps-extra"
BUILDDEPS_EXTRA = "${WORKDIR}/${BUILDDEPS_EXTRA_REPONAME}"

do_fetch_extra_upstream_builddeps() {
    mkdir -p "${BUILDDEPS_EXTRA}"
    for rpm in ${EXTRA_UPSTREAM}; do
        wget --directory-prefix="${BUILDDEPS_EXTRA}" $rpm
    done
}
do_fetch_extra_upstream_builddeps[network] = "1"

# only create this task if needed
python() {
    if d.getVar("EXTRA_UPSTREAM"):
        bb.build.addtask("do_fetch_extra_upstream_builddeps", "do_fetch_upstream_builddeps", "do_prepare_managed_builddeps", d)
        BUILDDEPS_EXTRA = d.getVar("BUILDDEPS_EXTRA")
        BUILDDEPS_EXTRA_REPONAME = d.getVar("BUILDDEPS_EXTRA_REPONAME")
        d.setVar("EXTRA_BUILD_FLAGS", f"--local-repo='{BUILDDEPS_EXTRA}' --enablerepo='{BUILDDEPS_EXTRA_REPONAME}'")
    else:
        d.setVar("EXTRA_BUILD_FLAGS", "")
}

BUILDDEPS_UPSTREAM_REPONAME = "bdeps-upstream"
# FIXME we want to share this under DL_DIR, but then only pass the
# requested ones to do_package
BUILDDEPS_UPSTREAM = "${WORKDIR}/${BUILDDEPS_UPSTREAM_REPONAME}"

# FIXME: this makes a copy of managed (and extra) builddeps
# Should ask dnf only for URLs?  dnf-builddep does not have --url like dnf-download :(
# Use "rpmbuild -bd" and dnf-download?
do_fetch_upstream_builddeps() {
    env XCPNG_OCI_RUNNER=podman xcp-ng-dev container builddep "9.0" "${BUILDDEPS_UPSTREAM}" "${S}" \
        --debug \
        --local-repo="${BUILDDEPS_MANAGED}" --enablerepo="${BUILDDEPS_MANAGED_REPONAME}" \
        ${EXTRA_BUILD_FLAGS} \
        --no-update --disablerepo=xcpng        
}
do_fetch_upstream_builddeps[network] = "1"
do_fetch_upstream_builddeps[depends] = "build-env:do_create"

addtask do_fetch_upstream_builddeps after do_prepare_managed_builddeps

# SSTATETASKS += "do_fetch_upstream_builddeps"
# do_package[sstate-plaindirs] = "${WORKDIR}/SRPMS ${WORKDIR}/RPMS"


XCPNGDEV_BUILD_OPTS ?= ""

# produces ${WORKDIR}/SRPMS and ${WORKDIR}/RPMS
# FIXME: lacks control of parallel building?
# FIXME: set _topdir to ${WORKDIR} to stop polluting source
do_package() {
    env XCPNG_OCI_RUNNER=podman xcp-ng-dev container build "9.0" "${S}" \
        --debug \
        --no-network --no-update --disablerepo="*" \
        --local-repo="${BUILDDEPS_MANAGED}" --enablerepo="${BUILDDEPS_MANAGED_REPONAME}" \
        ${EXTRA_BUILD_FLAGS} \
        --local-repo="${BUILDDEPS_UPSTREAM}" --enablerepo="${BUILDDEPS_UPSTREAM_REPONAME}" \
        --output-dir="${WORKDIR}" \
        ${XCPNGDEV_BUILD_OPTS}
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
