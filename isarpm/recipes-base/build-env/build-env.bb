# Recipe to create a build-env (and ultimately build packages from it).
# This is an XCP-ng *bootstrap* podman container to make sure we do not
# rely on any already-built XCP-ng package, just AlmaLinux ones.
#
# TODO: should actually be split between some generic support one one
# side, which the rpm class can rely on, and specific implementation
# for xcp-ng-build-env on another side.

SRC_URI = "git://github.com/xcp-ng/xcp-ng-build-env;protocol=https;branch=ydi/9"
SRCREV = "5a7dd23622c62f6da24565bf6ffb0f1ac569bbbb"

# FIXME: this ought to be "${WORKDIR}/git", what's wrong with unpack?
S = "${UNPACKDIR}/git"

do_create_bootstrap() {
    env XCPNG_OCI_RUNNER=podman ${S}/container/build.sh \
        --platform "${CONTAINER_ARCH}" \
        --bootstrap \
        9.0
}
# FIXME: temporary until we separately fetch the required RPMs
do_create_bootstrap[network] = "1"

addtask create_bootstrap after do_unpack

do_create() {
    env XCPNG_OCI_RUNNER=podman ${S}/container/build.sh \
        --platform "${CONTAINER_ARCH}" \
        --isarpm \
        --add-repo "release:${DEPLOY_DIR}/rpms/xcp-ng-release/RPMS" \
        9.0
}
# FIXME: temporary until we separately fetch the required RPMs
do_create[network] = "1"

addtask create
do_create[depends] = "xcp-ng-release:do_deploy"


RECIPE_DEPLOY_DIR = "${DEPLOY_DIR}/${PN}"

do_deploy() {
    rm -rf "${RECIPE_DEPLOY_DIR}"
    python3 -m venv "${RECIPE_DEPLOY_DIR}"
    . "${RECIPE_DEPLOY_DIR}"/bin/activate
    python3 -m pip install ${S}
}
# we don't want to depend too strictly on the python dependency chain, right?
do_deploy[network] = "1"

addtask deploy after do_unpack


# default target
do_build() {
}
addtask do_build after do_create
# override bitbake_base.bbclass
python() {
    d.delVarFlag("do_build", "nostamp")
}
