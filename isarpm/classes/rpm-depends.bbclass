DEPENDS ?= ""
PACKAGE_NEEDS_BOOTSTRAP ?= "0"

UPSTREAM_RPM_CACHEDIR = "${DL_DIR}/upstream"

# FIXME: xcp-ng-dev commands should be provided by build-env.class
XCPNGDEV = "${DEPLOY_DIR}/build-env/bin/xcp-ng-dev"


BUILDDEPS_MANAGED_REPONAME = "bdeps-managed"
BUILDDEPS_MANAGED = "${WORKDIR}/${BUILDDEPS_MANAGED_REPONAME}"

do_collect_managed_builddeps() {
    rm -rf "${BUILDDEPS_MANAGED}"
    mkdir -p "${BUILDDEPS_MANAGED}"
    for dep in ${DEPENDS}; do
        mkdir -p ${BUILDDEPS_MANAGED}/${dep}
        for rpmdir in RPMS rdeps-extra rdeps-managed rdeps-upstream; do
            if [ -d "${DEPLOY_DIR_ISARPM}/$dep/$rpmdir" ]; then
                cp -la "${DEPLOY_DIR_ISARPM}/$dep/$rpmdir" "${BUILDDEPS_MANAGED}/${dep}/"
            fi
        done
    done
    #createrepo_c --compatibility "${BUILDDEPS_MANAGED}"
}
addtask do_collect_managed_builddeps after do_unpack
do_collect_managed_builddeps[deptask] = "do_deploy"
do_collect_managed_builddeps[vardepsexclude] += "PACKAGE_EXTRA_ARCHS BB_TASKDEPDATA"


## FIXME: hack to rely on RPMs from Fedora etc until they reach EPEL10
# URLs of RPMs not yet in our official upstream
EXTRA_UPSTREAM_DEPENDS = ""

BUILDDEPS_EXTRA_REPONAME = "bdeps-extra"
BUILDDEPS_EXTRA = "${WORKDIR}/${BUILDDEPS_EXTRA_REPONAME}"

do_fetch_extra_upstream_builddeps() {
    mkdir -p "${BUILDDEPS_EXTRA}"
    for url in ${EXTRA_UPSTREAM_DEPENDS}; do
        rpm=$(basename "$url")
        if [ ! -e "${UPSTREAM_RPM_CACHEDIR}/$rpm" ]; then
            mkdir -p "${UPSTREAM_RPM_CACHEDIR}"
            curl --silent --show-error --fail --location \
                 --output-dir "${UPSTREAM_RPM_CACHEDIR}" --remote-name "$url"
        fi
        cp -l "${UPSTREAM_RPM_CACHEDIR}/$rpm" "${BUILDDEPS_EXTRA}/"
    done
}
do_fetch_extra_upstream_builddeps[network] = "1"

# only create this task if needed
python() {
    if d.getVar("EXTRA_UPSTREAM_DEPENDS"):
        bb.build.addtask("do_fetch_extra_upstream_builddeps", "do_collect_managed_builddeps", "do_unpack", d)
        BUILDDEPS_EXTRA = d.getVar("BUILDDEPS_EXTRA")
        BUILDDEPS_EXTRA_REPONAME = d.getVar("BUILDDEPS_EXTRA_REPONAME")
        d.setVar("EXTRA_BUILD_FLAGS", f"--local-repo='{BUILDDEPS_EXTRA}' --enablerepo='{BUILDDEPS_EXTRA_REPONAME}'")
    else:
        d.setVar("EXTRA_BUILD_FLAGS", "")
}
