REPONAME = "branding-xcp-ng"
SRC_URI = "git://github.com/xcp-ng-rpms/${REPONAME};protocol=https;nobranch=1"
SRCREV = "0928ed6764f883f1b9e5d827cb926f4236257a6d"

do_foobar() {
    bbwarn ${@d.getVar('SRC_URI')}
    bbwarn ${@bb.fetch2.get_srcrev(d)}
}
addtask do_foobar
