require install-image.inc

DEPENDS = "dnf-repo"

S = "${UNPACKDIR}/git"
B = "${WORKDIR}/out"

do_build() {
    rm -rf "${B}"
    mkdir -p "${B}"
    env XCPNG_OCI_RUNNER=podman ${XCPNGDEV} container run \
        --isarpm \
        --platform "${CONTAINER_ARCH}" \
        --debug \
        --no-update --install=kmod \
        -d "${S}" \
        -d "${B}" \
        -d "${DEPLOY_DIR}/repo/xcp-test" \
        "9.0" \
        -- sudo /external/$(basename ${S})/scripts/create-installimg.sh \
           --verbose \
           --pkgtool dnf \
           --arch ${RPM_ARCH} \
           --srcurl:8.99 file:///external/xcp-test/ \
           --output /external/$(basename ${B})/install.img \
           8.99
    # fix permission
    env XCPNG_OCI_RUNNER=podman ${XCPNGDEV} container run \
        --isarpm \
        --platform "${CONTAINER_ARCH}" \
        --no-update \
        -d "${B}" \
        "9.0" \
        -- sudo sudo chown builder:builder /external/$(basename ${B})/install.img
}
do_build[depends] = "build-env:do_deploy build-env:do_create"
addtask do_build after do_unpack

# override bitbake_base.bbclass
python() {
    d.delVarFlag("do_build", "nostamp")
}

# FIXME why would we need this?
# FIXME --no-network would need organizing ustream RPMs as more proper mirrors
do_build[network] = "1"


do_deploy() {
    mkdir -p "${DEPLOY_DIR_IMAGE}"
    cp -lf "${B}/install.img" "${DEPLOY_DIR_IMAGE}/"
}
addtask do_deploy after do_build
