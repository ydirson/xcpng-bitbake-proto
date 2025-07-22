DEPENDS ?= ""

do_build() {
    bbnote "hi"
    exit 1
}

addtask build after do_fetch
