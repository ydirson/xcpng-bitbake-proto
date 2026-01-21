RDEPENDS ?= ""

# note we don't bother separating RDEPENDS of each binary package, we
# store all those of a given source package together
RDEPS_MANAGED_REPONAME = "rdeps-managed"
RDEPS_MANAGED = "${WORKDIR}/${RDEPS_MANAGED_REPONAME}"

do_collect_managed_rdeps() {
    rm -rf "${RDEPS_MANAGED}"
    mkdir -p "${RDEPS_MANAGED}"
    for dep in ${RDEPENDS}; do
        mkdir -p ${RDEPS_MANAGED}/${dep}
        for rpmdir in RPMS rdeps-extra rdeps-managed rdeps-upstream; do
            if [ -d "${DEPLOY_DIR_ISARPM}/$dep/$rpmdir" ]; then
                cp -la "${DEPLOY_DIR_ISARPM}/$dep/$rpmdir" "${RDEPS_MANAGED}/${dep}/"
            fi
        done
    done
    createrepo_c --compatibility "${RDEPS_MANAGED}"
}
addtask do_collect_managed_rdeps after do_package

# Bitbake does not manage the binary packages so will not make use of
# RDEPENDS by itself, we have to add the dependencies ourselves.
# Would otherwise likely be:
#   do_collect_managed_rdeps[rdeptask] = "do_deploy"
python() {
    taskrdeps = ' '.join(f"{dep}:do_deploy" for dep in d.getVar("RDEPENDS").split())
    d.setVarFlag("do_collect_managed_rdeps", "depends", taskrdeps)
}
