inherit rpm-rdepends

RECIPE_DEPLOY_DIR = "${DEPLOY_DIR_ISARPM}/${PN}"

RDEPENDS ?= ""

# dummy target required by do_collect_managed_rdeps
do_package() {
    rm -rf "${WORKDIR}/RPMS" "${WORKDIR}/SRPMS"
    mkdir -p "${WORKDIR}/RPMS" "${WORKDIR}/SRPMS"
    cp -la "${UNPACKDIR}"/*.rpm "${WORKDIR}/RPMS/"
    mv "${WORKDIR}/RPMS/"*.src.rpm "${WORKDIR}/SRPMS/"
}
addtask do_package after do_unpack


# FIXME: dup of rpm.class for now, until do_fetch_upstream_rdeps dies
do_deploy() {
    rm -rf "${RECIPE_DEPLOY_DIR}"
    mkdir -p "${RECIPE_DEPLOY_DIR}"
    cp -la "${WORKDIR}/SRPMS" "${WORKDIR}/RPMS" "${RDEPS_MANAGED}" "${RECIPE_DEPLOY_DIR}/"
    if [ -n "${EXTRA_UPSTREAM_RDEPENDS}" ]; then
        cp -la "${RDEPENDS_EXTRA}" "${RECIPE_DEPLOY_DIR}/"
    fi
    find "${RECIPE_DEPLOY_DIR}/" -name repodata | xargs rm -r
}
addtask do_deploy after do_collect_managed_rdeps

# Make do_deploy depend on all DEPENDS' do_deploy
python() {
    taskrdeps = ' '.join(f"{dep}:do_deploy" for dep in d.getVar("RDEPENDS").split())
    d.setVarFlag("do_deploy", "depends", taskrdeps)
}
