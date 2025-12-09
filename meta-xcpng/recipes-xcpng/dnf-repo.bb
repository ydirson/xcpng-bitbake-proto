DEPENDS = "xcp-ng-deps"
DEPENDS += "host-installer"

# FIXME needed by install-image.bb, we could have the latter use the
# bb recipe instead
DEPENDS += "branding-xcp-ng"

TESTREPO_NAME = "xcp-test"
TESTREPO_DIR = "${DEPLOY_DIR}/repo/${TESTREPO_NAME}"
do_deploy() {
    rm -rf ${TESTREPO_DIR}
    mkdir -p ${TESTREPO_DIR}
    for dep in ${DEPENDS}; do
        _deploy_rpm "${DEPLOY_DIR}/rpms/$dep"
    done
    createrepo_c --compatibility ${TESTREPO_DIR}
}
addtask do_deploy
do_deploy[deptask] = "do_deploy"

_deploy_rpm() {
    dir="$1"
    rpmname=$(basename "$dir")
    # get each package once only
    [ ! -r "${TESTREPO_DIR}/$rpmname" ] || return 0
    cp -la "$dir/RPMS" "${TESTREPO_DIR}/$rpmname"
    # get rid of files making RPMS a yum repo
    rm -rf "${TESTREPO_DIR}/$rpmname/repodata" "${TESTREPO_DIR}/$rpmname/"*.repo

    if [ -r "$dir/rdeps-extra" ]; then
        mkdir -p "${TESTREPO_DIR}/extra"
        cp -la "$dir/rdeps-extra/"*.rpm "${TESTREPO_DIR}/extra/"
    fi
    rpms=$(echo "$dir/rdeps-upstream/"*.rpm)
    if [ "$rpms" != "$dir/rdeps-upstream/*.rpm" ]; then
        mkdir -p "${TESTREPO_DIR}/upstream"
        cp -la $rpms "${TESTREPO_DIR}/upstream/"
    fi
    for dep in "$dir/rdeps-managed"/*; do
        [ -d "$dep" ] || continue
        [ "$(basename $dep)" != "repodata" ] || continue
        _deploy_rpm $dep
    done
}

XCPNGDEV = "${DEPLOY_DIR}/build-env/bin/xcp-ng-dev"
do_test() {
    for dep in ${DEPENDS}; do
        for rpm in ${DEPLOY_DIR}/rpms/$dep/RPMS/*/*.rpm; do
            rpm=$(basename $rpm .rpm)
            env XCPNG_OCI_RUNNER=podman ${XCPNGDEV} container run \
                    --bootstrap \
                    --platform "${CONTAINER_ARCH}" \
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

# override bitbake_base.bbclass
python() {
    d.delVarFlag("do_build", "nostamp")
}
