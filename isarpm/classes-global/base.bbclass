inherit bitbake_base
inherit utility-tasks

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
    workdir = d.getVar('WORKDIR')
    if sourcedir.startswith(workdir) and not sourcedir.startswith(unpackdir):
        basedir = sourcedir.replace(workdir, '').strip("/").split('/')[0]
        if basedir:
            bb.utils.remove(workdir + '/' + basedir, True)
            d.setVar("SOURCE_BASEDIR", workdir + '/' + basedir)

    try:
        fetcher = bb.fetch2.Fetch(src_uri, d)
        fetcher.unpack(d.getVar('UNPACKDIR'))
    except bb.fetch2.BBFetchException as e:
        bb.fatal("Bitbake Fetcher Error: " + repr(e))

    if basedir and os.path.exists(unpackdir + '/' + basedir):
        # Compatibility magic to ensure ${WORKDIR}/git and ${WORKDIR}/${BP}
        # as often used in S work as expected.
        shutil.move(unpackdir + '/' + basedir, workdir + '/' + basedir)
}

EXPORT_FUNCTIONS do_fetch do_unpack

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
            srctool = bb.utils.which(path, tool, executable=True)
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

addhandler base_eventhandler
base_eventhandler[eventmask] = "bb.event.ConfigParsed bb.event.MultiConfigParsed bb.event.BuildStarted bb.event.RecipePreFinalise bb.event.RecipeParsed"
python base_eventhandler() {
    import bb.runqueue

    # There might be no bb.event.ConfigParsed event if bitbake server is
    # running, so check bb.event.BuildStarted too to make sure ${HOSTTOOLS_DIR}
    # exists.
    if isinstance(e, bb.event.ConfigParsed) or \
            (isinstance(e, bb.event.BuildStarted) and not os.path.exists(d.getVar('HOSTTOOLS_DIR'))):
        # Works with the line in layer.conf which changes PATH to point here
        setup_hosttools_dir(d.getVar('HOSTTOOLS_DIR'), 'HOSTTOOLS', d)
        setup_hosttools_dir(d.getVar('HOSTTOOLS_DIR'), 'HOSTTOOLS_NONFATAL', d, fatal=False)
}
