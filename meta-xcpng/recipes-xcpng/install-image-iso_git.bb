require install-image.inc

ISO_LABEL ?= "XCP-NG"

# FIXME this does not trigger anything, worked around through do_build[depends]
DEPENDS = "dnf-repo"

# FIXME: this is not a nice way
EXTRA_UPSTREAM_DEPENDS:x86-64-v2 = " \
https://epel.repo.almalinux.org/10/x86_64_v2/Packages/genisoimage-1.1.11-58.el10_1.alma_altarch.x86_64_v2.rpm \
  https://epel.repo.almalinux.org/10/x86_64_v2/Packages/libusal-1.1.11-58.el10_1.alma_altarch.x86_64_v2.rpm \
https://epel.repo.almalinux.org/10/x86_64_v2/Packages/libfaketime-0.9.12-4.el10_1.alma_altarch.x86_64_v2.rpm \
http://fr2.rpmfind.net/linux/almalinux/10.0/BaseOS/x86_64_v2/os/Packages/syslinux-6.04-0.30.el10.alma.1.x86_64_v2.rpm \
  http://fr2.rpmfind.net/linux/almalinux/10.0/BaseOS/x86_64_v2/os/Packages/syslinux-nonlinux-6.04-0.30.el10.alma.1.noarch.rpm \
"

S = "${UNPACKDIR}/git"
B = "${WORKDIR}/out"

do_build() {
    rm -rf "${B}"
    mkdir -p "${B}"
    createrepo_c --compatibility '${BUILDDEPS_EXTRA}'
    env XCPNG_OCI_RUNNER=podman ${XCPNGDEV} container run \
        --isarpm \
        --platform "${CONTAINER_ARCH}" \
        --debug \
        --no-update \
        --install=genisoimage --install=syslinux --install=grub2-tools \
        --install=createrepo_c --install=libfaketime \
        --disablerepo=* \
        --local-repo="${DEPLOY_DIR}/repo/xcp-test" --enablerepo=xcp-test \
        --local-repo='${BUILDDEPS_EXTRA}' --enablerepo='${BUILDDEPS_EXTRA_REPONAME}' \
        -d "${S}" \
        -d "${B}" \
        -d "${DEPLOY_DIR_IMAGE}" \
        "9.0" \
        -- /external/$(basename ${S})/scripts/create-iso.sh \
           --verbose \
           --pkgtool dnf \
           --arch ${RPM_ARCH} \
           --srcurl:8.99 file:///home/builder/local-repos/xcp-test/ \
           --output /external/$(basename ${B})/xcp-ng.iso \
           -V "${ISO_LABEL}" \
           8.99 /external/$(basename ${DEPLOY_DIR_IMAGE})/install.img
}
do_build[depends] = "build-env:do_deploy build-env:do_create install-image-installimg:do_deploy dnf-repo:do_deploy"
addtask do_build after do_fetch_extra_upstream_builddeps

# FIXME why would we need this?
# FIXME --no-network would need organizing ustream RPMs as more proper mirrors
do_build[network] = "1"

# override bitbake_base.bbclass
python() {
    d.delVarFlag("do_build", "nostamp")
}


do_deploy() {
    mkdir -p "${DEPLOY_DIR_IMAGE}"
    cp -lf "${B}/xcp-ng.iso" "${DEPLOY_DIR_IMAGE}/"
}
addtask do_deploy after do_build
