DEPENDS ?= ""

do_build() {
    xcp-ng-dev container build "${S}" 9.0 --rm --platform linux/amd64 --no-update
}
# FIXME: disabling network access through a user namespace currently
# prevents podman from starting, bitbake likely needs to learn.  See
# https://github.com/containers/podman/issues/15238
do_build[network] = "1"

addtask build after do_unpack
