inherit xcp-ng-rpm

SRCREV = "ab8f45d1170254d5655f08e6444949b5623f1c6c"

# add "noshared" to let git-describe work in the container, for the "-dirty" workaround
BB_GIT_NOSHARED = "1"

DEPENDS += " \
  ocaml \
  xen \
  xs-opam-repo \
  blktap \
  sm \
"
