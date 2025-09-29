DEPENDS = " \
  branding-xcp-ng \
"

TESTREPO_NAME = "xcp-test"
TESTREPO_DIR = "${DEPLOY_DIR}/repo/${TESTREPO_NAME}"
do_deploy() {
    rm -rf ${TESTREPO_DIR}
    mkdir -p ${TESTREPO_DIR}
    for dep in ${DEPENDS}; do
        cp -a "${DEPLOY_DIR}/rpms/${dep}/RPMS" "${TESTREPO_DIR}/${dep}"
    done
    createrepo_c --compatibility ${TESTREPO_DIR}
}
addtask do_deploy
do_deploy[deptask] = "do_deploy"


XCPNGDEV = "${DEPLOY_DIR}/build-env/bin/xcp-ng-dev"
do_test() {
    for dep in ${DEPENDS}; do
        env XCPNG_OCI_RUNNER=podman ${XCPNGDEV} container run \
                --debug \
                --no-network --no-update --disablerepo="*" \
                --local-repo="${TESTREPO_DIR}" --enablerepo="${TESTREPO_NAME}" \
            "9.0" \
            -- sudo dnf install -y $dep
    done
}
addtask do_test after do_deploy
# FIXME
do_test[network] = "1"

# default target
do_build() {
}
addtask do_build after do_deploy
