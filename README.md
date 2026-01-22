# maintenance

To workaround [a bug when running dnf on non-RPM
distros](https://github.com/rpm-software-management/libdnf/issues/1757),
you will need to use a container to run the bridge-builder script there.

To mirror the DNF state of Almalinux 10.0 into `meta-almalinux`, use:

```
podman run --rm --platform linux/amd64/v2 -it \
    -v $PWD:/dnf-bridge \
    ghcr.io/almalinux/10-base:10 \
    sh -c 'cd /dnf-bridge && ./scripts/gen-dnf-proxy'
```
