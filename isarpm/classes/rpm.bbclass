DEPENDS ?= ""
RDEPENDS ?= ""
PACKAGE_NEEDS_BOOTSTRAP ?= "0"
XCPNGDEV_BUILD_OPTS ?= ""

DEPLOY_DIR_ISARPM = "${DEPLOY_DIR}/rpms"
RECIPE_DEPLOY_DIR = "${DEPLOY_DIR_ISARPM}/${PN}"

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
                cp -a "${DEPLOY_DIR_ISARPM}/$dep/$rpmdir" "${BUILDDEPS_MANAGED}/${dep}/"
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
    for rpm in ${EXTRA_UPSTREAM_DEPENDS}; do
        curl --silent --show-error --fail --location \
             --output-dir "${BUILDDEPS_EXTRA}" --remote-name "$rpm"
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


BUILDDEPS_UPSTREAM_REPONAME = "bdeps-upstream"
# FIXME we want to share this under DL_DIR, but then only pass the
# requested ones to do_package
BUILDDEPS_UPSTREAM = "${WORKDIR}/${BUILDDEPS_UPSTREAM_REPONAME}"

# FIXME: managed RPM pulled by an upstream one will be missed
# FIXME: may need "rpmbuild -bd" as well for dynamic builddeps
do_fetch_upstream_builddeps() {
    BASE_S=$(basename ${S})
    SPEC=SPECS/${PN}.spec
    [ -r "${S}/$SPEC" ] || SPEC=${PN}.spec
    [ -r "${S}/$SPEC" ] || bbfatal "Cannot find ${PN}.spec"

    # FIXME should be an anynomous python block not copypasta
    case ${PACKAGE_NEEDS_BOOTSTRAP} in
    0) maybe_bootstrap= ;;
    1) maybe_bootstrap=--bootstrap ;;
    esac

    URLS=$(
        env XCPNG_OCI_RUNNER=podman ${XCPNGDEV} container run \
                $maybe_bootstrap \
                --debug \
                --local-repo="${BUILDDEPS_MANAGED}" --enablerepo="${BUILDDEPS_MANAGED_REPONAME}" \
                ${EXTRA_BUILD_FLAGS} \
                --no-update --disablerepo=xcpng \
                -d "${S}" \
                -v ${LAYERDIR_isarpm}/libexec/get-build-deps-urls.sh:/external/get-build-deps-urls.sh \
            "9.0" \
            -- /external/get-build-deps-urls.sh /external/${BASE_S}/${SPEC} /external/${BASE_S}
    )

    # FIXME use DL cache
    rm -rf "${BUILDDEPS_UPSTREAM}"
    mkdir -p "${BUILDDEPS_UPSTREAM}"
    for url in $URLS; do
        case "$url" in
            file://*) continue ;; # skip files we provide in local repos
        esac
        curl --silent --show-error --fail --location \
             --output-dir "${BUILDDEPS_UPSTREAM}" --remote-name "$url"
    done
}
do_fetch_upstream_builddeps[network] = "1"
do_fetch_upstream_builddeps[depends] = "build-env:do_deploy build-env:${@'do_create_bootstrap' if ${PACKAGE_NEEDS_BOOTSTRAP} else 'do_create' }"

addtask do_fetch_upstream_builddeps after do_collect_managed_builddeps

# SSTATETASKS += "do_fetch_upstream_builddeps"
# do_package[sstate-plaindirs] = "${WORKDIR}/SRPMS ${WORKDIR}/RPMS"


# produces ${WORKDIR}/SRPMS and ${WORKDIR}/RPMS
# FIXME: lacks control of parallel building?
# FIXME: set _topdir to ${WORKDIR} to stop polluting source
do_package() {
    rm -rf ${WORKDIR}/RPMS ${WORKDIR}/SRPMS

    case ${PACKAGE_NEEDS_BOOTSTRAP} in
    0) maybe_bootstrap= ;;
    1) maybe_bootstrap=--bootstrap ;;
    esac

    env XCPNG_OCI_RUNNER=podman ${XCPNGDEV} container build "9.0" "${S}" \
        $maybe_bootstrap \
        --debug \
        --no-network --no-update --disablerepo="*" \
        --local-repo="${BUILDDEPS_MANAGED}" --enablerepo="${BUILDDEPS_MANAGED_REPONAME}" \
        ${EXTRA_BUILD_FLAGS} \
        --local-repo="${BUILDDEPS_UPSTREAM}" --enablerepo="${BUILDDEPS_UPSTREAM_REPONAME}" \
        --output-dir="${WORKDIR}" \
        ${XCPNGDEV_BUILD_OPTS}
    createrepo_c --compatibility ${WORKDIR}/RPMS
}

addtask do_package after do_fetch_upstream_builddeps

SSTATETASKS += "do_package"
do_package[sstate-plaindirs] = "${WORKDIR}/SRPMS ${WORKDIR}/RPMS"

python do_package_setscene () {
    sstate_setscene(d)
}
addtask do_package_setscene


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
                cp -a "${DEPLOY_DIR_ISARPM}/$dep/$rpmdir" "${RDEPS_MANAGED}/${dep}/"
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


## FIXME: hack to rely on RPMs from Fedora etc until they reach EPEL10
# URLs of RPMs not yet in our official upstream
EXTRA_UPSTREAM_RDEPENDS = ""

RDEPENDS_EXTRA_REPONAME = "rdeps-extra"
RDEPENDS_EXTRA = "${WORKDIR}/${RDEPENDS_EXTRA_REPONAME}"

do_fetch_extra_upstream_rdepends() {
    mkdir -p "${RDEPENDS_EXTRA}"
    for rpm in ${EXTRA_UPSTREAM_RDEPENDS}; do
        curl --silent --show-error --fail --location \
             --output-dir "${RDEPENDS_EXTRA}" --remote-name "$rpm"
    done
}
do_fetch_extra_upstream_rdepends[network] = "1"

# only create this task if needed
python() {
    if d.getVar("EXTRA_UPSTREAM_RDEPENDS"):
        bb.build.addtask("do_fetch_extra_upstream_rdepends", "do_collect_managed_rdeps", "do_package", d)
        RDEPENDS_EXTRA = d.getVar("RDEPENDS_EXTRA")
        RDEPENDS_EXTRA_REPONAME = d.getVar("RDEPENDS_EXTRA_REPONAME")
        d.setVar("EXTRA_RUN_FLAGS", f"--local-repo='{RDEPENDS_EXTRA}' --enablerepo='{RDEPENDS_EXTRA_REPONAME}'")
    else:
        d.setVar("EXTRA_RUN_FLAGS", "")
}


RDEPS_UPSTREAM_REPONAME = "rdeps-upstream"
# FIXME we want to share this under DL_DIR, but then only pass the
# requested ones to do_package
RDEPS_UPSTREAM = "${WORKDIR}/${RDEPS_UPSTREAM_REPONAME}"

# FIXME: find a way to collect errors from all RPMs in a single run, rather
# than stopping on first error
do_fetch_upstream_rdeps() {
    BASE_S=$(basename ${S})
    SPEC=SPECS/${PN}.spec
    [ -r "${S}/$SPEC" ] || SPEC=${PN}.spec
    [ -r "${S}/$SPEC" ] || bbfatal "Cannot find ${PN}.spec"

    # FIXME should be an anynomous python block not copypasta
    case ${PACKAGE_NEEDS_BOOTSTRAP} in
    0) maybe_bootstrap= ;;
    1) maybe_bootstrap=--bootstrap ;;
    esac

    URLS=$(
        set -o pipefail # FIXME bashism?
        for rpm in ${WORKDIR}/RPMS/*/*.rpm; do
            rpm=$(basename $rpm .rpm)
            env XCPNG_OCI_RUNNER=podman ${XCPNGDEV} container run \
                    $maybe_bootstrap \
                    --debug \
                    --local-repo="${PN}:${WORKDIR}/RPMS" --enablerepo="${PN}" \
                    --local-repo="${RDEPS_MANAGED}" --enablerepo="${RDEPS_MANAGED_REPONAME}" \
                    ${EXTRA_RUN_FLAGS} \
                    --no-update --disablerepo=xcpng \
                "9.0" \
                -- dnf download --quiet --resolve --urls $rpm
        done | sort -u
    )

    # FIXME use DL cache
    rm -rf "${RDEPS_UPSTREAM}"
    mkdir -p "${RDEPS_UPSTREAM}"
    for url in $URLS; do
        case "$url" in
            file://*) continue ;; # skip files we provide in local repos, including rpms from this recipe
        esac
        curl --silent --show-error --fail --location \
             --output-dir "${RDEPS_UPSTREAM}" --remote-name "$url"
    done
}
do_fetch_upstream_rdeps[network] = "1"
do_fetch_upstream_rdeps[depends] = "build-env:do_deploy build-env:${@'do_create_bootstrap' if ${PACKAGE_NEEDS_BOOTSTRAP} else 'do_create' }"

addtask do_fetch_upstream_rdeps after do_collect_managed_rdeps


# FIXME: should be removed by do_clean?
do_deploy() {
    rm -rf "${RECIPE_DEPLOY_DIR}"
    mkdir -p "${RECIPE_DEPLOY_DIR}"
    cp -a "${WORKDIR}/SRPMS" "${WORKDIR}/RPMS" "${RDEPS_MANAGED}" "${RDEPS_UPSTREAM}" "${RECIPE_DEPLOY_DIR}/"
}
addtask do_deploy after do_fetch_upstream_rdeps


do_test() {
    for rpm in ${WORKDIR}/RPMS/*/*.rpm; do
        env XCPNG_OCI_RUNNER=podman ${XCPNGDEV} container run \
                --bootstrap \
                --debug \
                --no-network --no-update --disablerepo="*" \
                --local-repo="${PN}:${WORKDIR}/RPMS" --enablerepo="${PN}" \
                --local-repo="${PN}-rdeps-managed:${RDEPS_MANAGED}" --enablerepo="${PN}-rdeps-managed" \
                --local-repo="${PN}-rdeps-upstream:${RDEPS_UPSTREAM}" --enablerepo="${PN}-rdeps-upstream" \
                ${EXTRA_RUN_FLAGS} \
            "9.0" \
            -- sudo dnf install -y $(basename $rpm .rpm)
    done
}
addtask do_test after do_fetch_upstream_rdeps
# FIXME: for some reason podman "cannot set up namespace"
# ... but this is mitigated by repo disabling
do_test[network] = "1"


# default target
do_build() {
}
addtask do_build after do_deploy
# override bitbake_base.bbclass
python() {
    d.delVarFlag("do_build", "nostamp")
}
