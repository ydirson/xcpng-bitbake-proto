DEPENDS = " \
  branding-xcp-ng \
  xcp-ng-release \
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
        for rpm in ${DEPLOY_DIR}/rpms/$dep/RPMS/*/*.rpm; do
            rpm=$(basename $rpm .rpm)
            env XCPNG_OCI_RUNNER=podman ${XCPNGDEV} container run \
                    --bootstrap \
                    --debug \
                    --no-network --no-update --disablerepo="*" \
                    --local-repo="${TESTREPO_DIR}" --enablerepo="${TESTREPO_NAME}" \
                "9.0" \
                -- sudo dnf install -y $rpm
        done
    done
}
addtask do_test after do_deploy
# FIXME
do_test[network] = "1"

# default target
do_build() {
}
addtask do_build after do_deploy
