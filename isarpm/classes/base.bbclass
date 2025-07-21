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

EXPORT_FUNCTIONS do_fetch
