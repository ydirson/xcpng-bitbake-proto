#
# Copyright OpenEmbedded Contributors
#
# SPDX-License-Identifier: MIT
#

inherit bitbake_base

BB_DEFAULT_TASK ?= "build"

inherit utility-tasks

def setup_hosttools_dir(dest, toolsvar, d, fatal=True):
    tools = d.getVar(toolsvar).split()
    origbbenv = d.getVar("BB_ORIGENV", False)
    path = origbbenv.getVar("PATH")
    # Need to ignore our own scripts directories to avoid circular links
    for p in path.split(":"):
        if p.endswith("/scripts"):
            path = path.replace(p, "/ignoreme")
    bb.utils.mkdirhier(dest)
    notfound = []
    for tool in tools:
        desttool = os.path.join(dest, tool)
        if not os.path.exists(desttool):
            # clean up dead symlink
            if os.path.islink(desttool):
                os.unlink(desttool)

            # Prefer gnu-prefixed binaries, if available
            srctool = (bb.utils.which(path, "gnu" + tool, executable=True) or
                       bb.utils.which(path, tool, executable=True))

            # gcc/g++ may link to ccache on some hosts, e.g.,
            # /usr/local/bin/ccache/gcc -> /usr/bin/ccache, then which(gcc)
            # would return /usr/local/bin/ccache/gcc, but what we need is
            # /usr/bin/gcc, this code can check and fix that.
            if os.path.islink(srctool) and os.path.basename(os.readlink(srctool)) == 'ccache':
                srctool = bb.utils.which(path, tool, executable=True, direction=1)
            if srctool:
                os.symlink(srctool, desttool)
            else:
                notfound.append(tool)

    if notfound and fatal:
        bb.fatal("The following required tools (as specified by HOSTTOOLS) appear to be unavailable in PATH, please install them in order to proceed:\n  %s" % " ".join(notfound))

# We can't use vardepvalue against do_fetch directly since that would overwrite
# the other task dependencies so we use an indirect function.
python fetcher_hashes_dummyfunc() {
    return
}
fetcher_hashes_dummyfunc[vardepvalue] = "${@bb.fetch.get_hashvalue(d)}"

addtask fetch
do_fetch[dirs] = "${DL_DIR}"
do_fetch[file-checksums] = "${@bb.fetch.get_checksum_file_list(d)}"
#do_fetch[file-checksums] += " ${@get_lic_checksum_file_list(d)}"
do_fetch[prefuncs] += "fetcher_hashes_dummyfunc"
do_fetch[network] = "1"
do_fetch[umask] = "${OE_SHARED_UMASK}"
python base_do_fetch() {

    src_uri = (d.getVar('SRC_URI') or "").split()
    if not src_uri:
        return

    try:
        fetcher = bb.fetch2.Fetch(src_uri, d)
        fetcher.download()
    except bb.fetch2.BBFetchException as e:
        bb.fatal("Bitbake Fetcher Error: " + repr(e))
}

addtask unpack after do_fetch
do_unpack[cleandirs] = "${UNPACKDIR}"

python base_do_unpack() {
    import shutil

    sourcedir = d.getVar('S')
    # Intentionally keep SOURCE_BASEDIR internal to the task just for SDE
    d.setVar("SOURCE_BASEDIR", sourcedir)

    src_uri = (d.getVar('SRC_URI') or "").split()
    if not src_uri:
        return

    basedir = None
    unpackdir = d.getVar('UNPACKDIR')
    if sourcedir.startswith(unpackdir):
        basedir = sourcedir.replace(unpackdir, '').strip("/").split('/')[0]
        if basedir:
            d.setVar("SOURCE_BASEDIR", unpackdir + '/' + basedir)

    try:
        fetcher = bb.fetch2.Fetch(src_uri, d)
        fetcher.unpack(d.getVar('UNPACKDIR'))
    except bb.fetch2.BBFetchException as e:
        bb.fatal("Bitbake Fetcher Error: " + repr(e))
}

SSTATETASKS += "do_deploy_source_date_epoch"

do_deploy_source_date_epoch () {
    mkdir -p ${SDE_DEPLOYDIR}
    if [ -e ${SDE_FILE} ]; then
        echo "Deploying SDE from ${SDE_FILE} -> ${SDE_DEPLOYDIR}."
        cp -p ${SDE_FILE} ${SDE_DEPLOYDIR}/__source_date_epoch.txt
    else
        echo "${SDE_FILE} not found!"
    fi
}

EXPORT_FUNCTIONS do_fetch do_unpack


def get_source_date_epoch_value(d):
    return oe.reproducible.epochfile_read(d.getVar('SDE_FILE'), d)

def get_layers_branch_rev(d):
    revisions = oe.buildcfg.get_layer_revisions(d)
    layers_branch_rev = ["%-20s = \"%s:%s\"" % (r[1], r[2], r[3]) for r in revisions]
    i = len(layers_branch_rev)-1
    p1 = layers_branch_rev[i].find("=")
    s1 = layers_branch_rev[i][p1:]
    while i > 0:
        p2 = layers_branch_rev[i-1].find("=")
        s2= layers_branch_rev[i-1][p2:]
        if s1 == s2:
            layers_branch_rev[i-1] = layers_branch_rev[i-1][0:p2]
            i -= 1
        else:
            i -= 1
            p1 = layers_branch_rev[i].find("=")
            s1= layers_branch_rev[i][p1:]
    return layers_branch_rev


BUILDCFG_FUNCS ??= "buildcfg_vars get_layers_branch_rev buildcfg_neededvars"
BUILDCFG_FUNCS[type] = "list"

def buildcfg_vars(d):
    statusvars = oe.data.typed_value('BUILDCFG_VARS', d)
    for var in statusvars:
        value = d.getVar(var)
        if value is not None:
            yield '%-20s = "%s"' % (var, value)

def buildcfg_neededvars(d):
    needed_vars = oe.data.typed_value("BUILDCFG_NEEDEDVARS", d)
    pesteruser = []
    for v in needed_vars:
        val = d.getVar(v)
        if not val or val == 'INVALID':
            pesteruser.append(v)

    if pesteruser:
        bb.fatal('The following variable(s) were not set: %s\nPlease set them directly, or choose a MACHINE or DISTRO that sets them.' % ', '.join(pesteruser))

addhandler base_eventhandler
base_eventhandler[eventmask] = "bb.event.ConfigParsed bb.event.MultiConfigParsed bb.event.BuildStarted bb.event.RecipePreFinalise bb.event.RecipeParsed"
python base_eventhandler() {

    # There might be no bb.event.ConfigParsed event if bitbake server is
    # running, so check bb.event.BuildStarted too to make sure ${HOSTTOOLS_DIR}
    # exists.
    if isinstance(e, bb.event.ConfigParsed) or \
            (isinstance(e, bb.event.BuildStarted) and not os.path.exists(d.getVar('HOSTTOOLS_DIR'))):
        # Works with the line in layer.conf which changes PATH to point here
        setup_hosttools_dir(d.getVar('HOSTTOOLS_DIR'), 'HOSTTOOLS', d)
        setup_hosttools_dir(d.getVar('HOSTTOOLS_DIR'), 'HOSTTOOLS_NONFATAL', d, fatal=False)
}
