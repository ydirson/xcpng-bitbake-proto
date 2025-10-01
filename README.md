# bitbake for XCP-ng

This is a set of Bitbake classes and recipes to build packages that
make up a XCP-ng distribution, on top of an upstream distribution
(namely AlmaLinux 10 + EPEL).  The intention is to build XCP-ng 9.0
with such a system.

Note: although there is some level of separation between generic code
and XCP-ng/Alma-specific code, this is essentially a prototype, don't
count on reusability yet.

## status

* prototype
* content limitations
  * can only generate part of the packages that make up XCP-ng, some
    of them not even having the XCP-ng patches added onto the newer
    upstream version
  * no usable repository or installation ISO yet
  * x86_64-v2 arch only
* tooling limitations
  * no caching of RPMs downloaded from upstream Alma/EPEL/Fedora
  * native build only (no cross-compilation)
  * no support for some features we don't seem to need yet:
    * rpm dynamic build requirements

## quick start

Setup a build environment:

```
. oe-init-build-env
```

Build all recipes (packages, repositories, images):

```
bitbake world
```

## recipe classes

Those are the `.bb` files under `meta-xcpng/recipes-*/`.

### `xcp-ng-rpm`

Describes how to build RPM packages (artifacts) from a specfile in a
RPM source repository, and how to produce repositories including all
packages required to install those RPM packages.

**Minimal example**:
[libempserver](meta-xcpng/recipes-xcpng/libempserver_git.bb) is a
package without any build dependencies, and whose RPM artifacts have
no dependency outside of the upstream distro (i.e. none that we build
from another recipe).

**Baseline example**:
[xs-opam-repo](meta-xcpng/recipes-xcpng/xs-opam-repo_git.bb) is a
package declaring both build-time dependencies (`DEPENDS`) and
run-time depends (`RDEPENDS`) on other recipes.  Both are slightly
different from the `BuildRequires` and `Requires` fields in the RPM
specfile:

* the recipe fields use the name of the recipe (which is the name of
  the SRPM package, and the name of the git repository holding it),
  whereas the specfile fields refer to (something provided by) RPM
  packages built out of those
* the specfile fields do not know which packages come from upstream
  distro, and which ones we build from other recipes
  
**Complex example**: [xen](meta-xcpng/recipes-xcpng/xen_git.bb), in
addition to the above, currently relies, both for at build-time and at
run-time, on Fedora packages we hope to get into upstream EPEL, but
are not yet there, and we currently pull the RPMs from Fedora directly
rather than building them ourselves.  This is done by specifying
direct URLs to the relevant RPMs, respectively using
`EXTRA_UPSTREAM_DEPENDS` and `EXTRA_UPSTREAM_RDEPENDS`.

The guidelines we use for AlmaLinux10-compatible RPMs is:
* pick most packages from Fedora 41
* pick python packages from Fedora 40 (which has the same python
  interpreter version)

#### filling those `*DEPENDS` variables

Looking at the specfile with `grep` is the best way to identify build
dependencies, looking at the generated RPMs's `Requires` fields is the
best way to identify runtime ones.

If any packages are missed for retrievial by one task, the next step
one will error out and you will see in the task log what packages
should be added to the previous task.  E.g., if you miss a recipe in
`DEPENDS` (used by the `do_collect_managed_builddeps` task, then the
`do_fetch_upstream_builddeps` will try to find the relevant packages
in Alma, and will fail (unless we're talking about a package that
*also exists in Alma*, which adds yet another reason to avoid that
situation).

## dev cheat sheet

### configuration

Those are example of stuff you may find useful to add in your `conf/local.conf`
(we might move those to the `local.conf` template).

Activate `ccache` for all (C/C++) package builds (one cache per package, outside of
TMPDIR to avoid loosing it on `rm -rf tmp`:
```
XCPNGDEV_BUILD_OPTS:append = " --ccache=${TOPDIR}/ccache/${PF}"
```

Reduce number of concurrent jobs for `kernel` package:
```
XCPNGDEV_BUILD_OPTS:append:pn-kernel = " --define '_smp_mflags -j3'"
```


### recipes

Take a commit from a local working clone:

```
SRC_URI = "git://localhost/home/user/src/xcpng/build-env/;protocol=file;nobranch=1"
```
