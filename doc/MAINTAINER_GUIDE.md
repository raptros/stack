<div class="hidden-warning"><a href="https://docs.haskellstack.org/"><img src="https://rawgit.com/commercialhaskell/stack/master/doc/img/hidden-warning.svg"></a></div>

# Maintainer guide

## Next release:

* @@@ get_stack.sh:
    * @@@ TEST armv7 (ubuntu)
    * @@@ TEST aarch64 (ubuntu, debian)
    * @@@ TEST centos 6 64-bit gmp4
    * @@@ TEST centos 7 64-bit standard
    * @@@ TEST centos6 32-bit gmp4 SHOULD FAIL (no longer exists)
    * @@@ TEST sloppy aarch64
* @@@ check that aarch64 link in install docs works after 1.7.1 released
* @@@ close https://github.com/commercialhaskell/stack/issues/3954 once v1.7.1 released
* @@@ remove `-nopie` variants from stack-setup-2.yaml (stack-1.7 will no longer use them, so wait a few more major releases)
* @@@ look into https://github.com/tfausak/github-release
* @@@ upgrade to freebsd 11.1 for build?
* @@@ switch to debian 8 for building linux binaries, to match GHC?
* @@@ NOTE: that stack-nightly removed, since only nightlies older than LTS-11 work
- @@@ perhaps remove static from https://github.com/fpco/stackage-content/blob/master/stack/releases.yamlhttps://github.com/fpco/stackage-content/blob/master/stack/releases.yaml

## Version scheme

* Versions with an _even_ third component (e.g. 1.6.2 and 1.7.0) are unreleased development versions
* Versions with an _odd_ third component (e.g. 1.6.1 or 1.7.3) and released versions
* Pre-release and release candidate binaries will be released with an even third component and the date as the fourth component (e.g. 1.6.0.20171129)
* All branches _except_ `release` (which matches exactly the most recent release) must have an even third component (development)
* Branches other than `stable` and `release` will always have a `0` third component (e.g. 1.7.0).

## Pre-release checks

* Check for any P0 and P1 issues that should be dealt with before release
* Check for un-merged pull requests that should be merged before release
* Ensure `release` and `stable` branches merged to `master`
* Check compatibility with latest LTS Stackage snapshots
    * `stack-*.yaml` (where `*` is not `nightly`), __including the ones in
      subdirectories__: bump to use latest LTS minor
      version (be sure any extra-deps that exist only for custom flags have
      versions matching the snapshot)
    * Check for any redundant extra-deps
    * Run `stack --stack-yaml=stack-*.yaml test --pedantic` (replace `*` with
      the actual file)
* Check compatibility with latest nightly stackage snapshot:
    * Update `stack-nightly.yaml` with latest nightly and remove unnecessary extra-deps (be
      sure any extra-deps that exist only for custom flags have versions
      matching the snapshot)
    * Run `stack --stack-yaml=stack-nightly.yaml test --pedantic`
* [@@@ SKIP] Check compatibility with latest Hackage:
    [@@@ export PATH=$(stack --stack-yaml=stack-nightly.yaml path --compiler-bin):$PATH
    [@@@ check for any bounds preventing use of latest packages (note that deprecated packes will show up in this list; ignore those): cabal sandbox delete; stack build --stack-yaml=stack-nightly.yaml --dry-run && cabal sandbox init && cabal update && PATH=$(stack --stack-yaml=stack-nightly.yaml path --compiler-bin):$PATH cabal install --enable-test --enable-bench --dry-run | grep latest]
    [@@@ try building with latest allowed by bounds:
    PATH=$(stack --stack-yaml=stack-nightly.yaml path --compiler-bin):$PATH cabal install --only-dependencies && cabal install --enable-test -f integration-tests
    @@@]
* Ensure integration tests pass on a Windows, macOS, and Linux (Linux
  integration tests are run
  by
  [Gitlab](http://gitlab.fpcomplete.com/fpco-mirrors/stack/pipelines)):
  `stack install --pedantic && stack test --pedantic --flag
  stack:integration-tests`. The actual release script will perform a more
  thorough test for every platform/variant prior to uploading, so this is just a
  pre-check

## Release preparation

* In master branch:
    * `package.yaml`: bump to next release candidate version (add a `.1` patchlevel, e.g. `X.Y.0.1`)
    * `ChangeLog.md`
        * Rename the "Unreleased changes" section to the same version as package.yaml, and mark it clearly as a release candidate (e.g. `vX.Y.0.1 (release candidate)`).  Remove any empty sections.
        * [@@@ SKIP] Check for any important changes that missed getting an entry in
          Changelog (`git log origin/stable...HEAD`)
        * Check for any entries that snuck into the previous version's changes
          due to merges (`git diff origin/stable HEAD ChangeLog.md`)

* Cut a release candidate branch `vX.Y.0` from master

* In master branch:
    * package.yaml: bump version to next major (second) component with `.0` third component (e.g. from 1.6.2 to 1.7.0)
    * Changelog: add new "Unreleased changes" section:
      ```
      ## Unreleased changes

      Release notes:

      Major changes:

      Behavior changes:

      Other enhancements:

      Bug fixes:
      ```

* In RC branch:
    * Review documentation for any changes that need to be made
        * Ensure all documentation pages listed in `mkdocs.yaml`
          (`git diff --stat origin/stable..HEAD doc/`)
        * Any new documentation pages should have the "may not be correct for
          the released version of Stack" warning at the top.
        * Search for old Stack version, unstable stack version, and the next
          "obvious" version in sequence (if doing a non-obvious jump), and
          `UNRELEASED` and replace with next release version (`X.Y.1`).
        * Look for any links to "latest" documentation, replace with version tag
    * Update `.github/ISSUE_TEMPLATE.md` to point at the new release version (`X.Y.1).
    * Check for new major [FreeBSD release](https://www.freebsd.org/releases/).  If so, add a `Vagrantfile` for it in `etc/vagrant/freebsd-X.Y-amd64` and update `etc/scripts/vagrant-releases.hs`
    * Check that for any platform entries that need to be added to (or removed from)
      [releases.yaml](https://github.com/fpco/stackage-content/blob/master/stack/releases.yaml),
      [install_and_upgrade.md](https://github.com/commercialhaskell/stack/blob/master/doc/install_and_upgrade.md), [get-stack.sh](https://github.com/commercialhaskell/stack/blob/master/etc/scripts/get-stack.sh), and [doc/README.md](https://github.com/commercialhaskell/stack/blob/master/doc/README.md).

* Follow steps in *Release process* below tagged with `[RC]` to make a release candidate

* For subsequent release candidates:
    * Re-do the pre-release checkes (above section)
    * `package.yaml`: bump to next odd patchlevel version (e.g. `X.Y.0.3`)
    * `ChangeLog.md`: Rename the "Unreleased changes" section to the new version, clearly marked as a release candidate (e.g. `vX.Y.0.3 (release candidate)`).  Remove any empty sections.
    * Follow steps in *Release process* below tagged with `[RC]` to make a release candidate

* For final release:
    * `package.yaml`: bump version to odd last component and no patchlevel (e.g. from `X.Y.0.2` to `X.Y.1`).
    * `ChangeLog.md`: consolidate all the RC changes into a single section for the release version
    * Follow all steps in the *Release process* section below.


## Release process

See
[stack-release-script's README](https://github.com/commercialhaskell/stack/blob/master/etc/scripts/README.md#prerequisites)
for requirements to perform the release, and more details about the tool.

A note about the `etc/scripts/*-releases.sh` scripts: if you run them from a
different working tree than the scripts themselves (e.g. if you have `stack1`
and `stack2` trees, and run `cd stack1; ../stack2/etc/scripts/vagrant-release.sh`)
the scripts and Vagrantfiles from the
tree containing the script will be used to build the stack code in the current
directory. That allows you to iterate on the release process while building a
consistent and clean stack version.

* Create a
  [new draft Github release](https://github.com/commercialhaskell/stack/releases/new)
  with tag and name `vX.Y.Z` (where X.Y.Z matches the version in `package.yaml` from the previous step), targeting the RC branch.  In the case of a release candidate, add `(RELEASE CANDIDATE)` to the name field.  check the *This is a pre-release* checkbox.  `[RC]`

* On each machine you'll be releasing from, set environment variable `GITHUB_AUTHORIZATION_TOKEN`. `[RC]`

* On a machine with Vagrant installed: `[RC]`
    * Run `etc/scripts/vagrant-releases.sh`

* On macOS: `[RC]`
    * Run `etc/scripts/osx-release.sh`

* On Windows: `[RC]`
    * Use a short path for your working tree (e.g. `C:\p\stack-release`
    * Ensure that STACK_ROOT, TEMP, and TMP are set to short paths
    * Run `etc\scripts\windows-releases.bat` (for release candidates, only 64-bit is necessary so feel free to comment out 32-bit)
    * Release Windows installers. See
      [stack-installer README](https://github.com/borsboom/stack-installer#readme).
      For release candidates, the windows installers can be skipped.

* On Linux ARMv7: `[RC]`
    * Run `etc/scripts/linux-armv7-release.sh`

* On Linux ARM64 (aarch64): `[RC]`
    * Run `etc/scripts/linux-aarch64-release.sh`

* Build sdist using `stack sdist .`, and upload it to the
  Github release with a name like `stack-X.Y.Z-sdist-0.tar.gz`.
  [@@@ copy to `_release` and then use release script to upload sigs and checksums]

    mv /Users/manny/fpco/stack-release/.stack-work/dist/x86_64-osx/Cabal-1.24.2.0/stack-X.Y.Z.tar.gz _release/stack-1.6.5-sdist-0.tar.gz
    stack-release-script _release/stack-1.6.5-sdist-0.tar.gz.upload _release/stack-1.6.5-sdist-0.tar.gz.asc.upload _release/stack-1.6.5-sdist-0.tar.gz.sha256.upload

* Use `etc/scripts/sdist-with-bounds.sh` to generate a Cabal spec and sdist with dependency bounds.

* Upload `_release/stack-X.Y.Z-sdist-1.tar.gz` to the Github release.
  [@@@ copy to `_release` and then use release script to upload sigs and checksums]

* Publish Github release. Include the changelog and in the description and use e.g. `git shortlog -s origin/release..HEAD|sed $'s/^[0-9 \t]*/* /'|sort -f` to get the list of contributors.

* Push signed Git tag, matching Github release tag name, e.g.: `git tag -d vX.Y.Z; git tag -s -m vX.Y.Z vX.Y.Z && git push -f origin vX.Y.Z`.  `[RC]`

* Upload package to Hackage: `stack upload .`

* Make a revision on Hackage using the bounds from `_release/stack-X.Y.Z_bounds.cabal`.

* Reset the `release` branch to the released commit, e.g.: `git checkout release && git merge --ff-only vX.Y.Z && git push origin release`

* Update the `stable` branch similarly

* In the `stable` or, in the case of a release candidate, `vX.Y.0` branch: `[RC]`
    * package.yaml: bump the version number even third component (e.g. from 1.6.1 to 1.6.2) or, in the case of a release candidate even _fourth_ component.
    * ChangeLog: Add an "Unreleased changes" section:

        ```
        ## Unreleased changes

        Release notes:

        Major changes:

        Behavior changes:

        Other enhancements:

        Bug fixes:
        ```

* Activate version for new release tag (or, in the case of release candidates, the `vX.Y.0` branch), on
  [readthedocs.org](https://readthedocs.org/dashboard/stack/versions/), and
  ensure that stable documentation has updated.  `[RC]`

* Deactivate version for release candidate on [readthedocs.org](https://readthedocs.org/dashboard/stack/versions/).

* Update [get.haskellstack.org /stable rewrite rules](https://gitlab.fpcomplete.com/fpco/devops/blob/develop/kubernetes/fpco-prod-v2/90_nginx-prod-v2_deployment.yaml) (be sure to change both places) to new released version, and update production cluster.

* Delete the RC branch (locally and on origin)

* Merge any changes made in the RC/release/stable branches to master (be careful about version and changelog).  `[RC]`

* [@@@ SKIP; no longer doing distro releases] On a machine with Vagrant installed:
    * Make sure you are on the same commit as when `vagrant-release.sh` was run.
    * Set environment variables: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`.
      Note: since one of the tools (rpm-s3 on CentOS) doesn't support AWS temporary credentials, you can't use MFA with the AWS credentials (`AWS_SECURITY_TOKEN` is ignored).
    * Run `etc/scripts/vagrant-distros.sh`

* Upload haddocks to Hackage: `etc/scripts/upload-haddocks.sh` (if they weren't auto-built)

* Update fpco/stack-build Docker images with new version

* Announce to haskell-cafe@haskell.org, haskell-stack@googlegroups.com,
  commercialhaskell@googlegroups.com mailing lists. `[RC]`

* Keep an eye on the
  [Hackage matrix builder](http://matrix.hackage.haskell.org/package/stack)

* Add back to stackage nightly if fallen out

## Setting up a Windows VM for releases

These instructions are a bit rough, but has the steps to get the Windows machine
set up.

 1. Download VM image:
    https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/mac/

 2. Launch the VM using Virtualbox and the image downloaded

 3. Adjust settings:
    * Number of CPUs: at least half the host's
    * Memory: at least 3 GB
    * Video RAM: the minimum recommended by Virtualbox
    * Enable 3D and 2D accelerated mode (this makes programs with lots of console output much faster)
    * Enabled shared clipboard (in VM window, Devices->Shared Clipboard->Both Directions)

 4. [@@@ TODO] Install the VMware guest additions, and reboot

 5. [@@@ TODO] In **Settings**->**Update & Security**->**Windows Update**->**Advanced options**:
     * Change **Choose how updates are installed** to **Notify to schedule restart**
     * Check **Defer upgrades**

 7. @@@ SKIP: Install Windows SDK (for signtool):
    http://microsoft.com/en-us/download/confirmation.aspx?id=8279

 8. Install msysgit: https://msysgit.github.io/

 9. Install nsis-2.46.5-Unicode-setup.exe from http://www.scratchpaper.com/

10. Install Stack using the Windows 64-bit installer

    a. Restart any command prompts to ensure they get new `%STACK_ROOT%` value.

11. Visit https://hackage.haskell.org/ in Edge to ensure system has correct CA
    certificates

12. @@@ SKIP Obtain a code signing certificate.
    Double click it in explorer and import it.  If you do not have a signing certificate,
    there are various CAs that will issue them.  As of this writing, the least expensive option is an [Open Source Code Signing certificate from Certum](https://www.certum.eu/certum/cert,offer_en_open_source_cs.xml)

13. Run in command prompt:

        md C:\p
        md C:\tmp
        cd /d C:\p

14. Create `C:\p\env.bat`:

        SET TEMP=C:\tmp
        SET TMP=C:\tmp
        SET PATH=C:\Users\IEUser\AppData\Roaming\local\bin;"c:\Program Files\Git\usr\bin";"C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin";%PATH%

15. Run `C:\p\env.bat` (do this every time you open a new command prompt)

16. [@@@ TODO] Import the `dev@fpcomplete.com` (0x575159689BEFB442) GPG secret key

17. Run in command prompt (adjust the `user.email` and `user.name` settings):

        stack --install-ghc install cabal-install
        stack install cabal-install
        git config --global user.email manny@fpcomplete.com
        git config --global user.name "Emanuel Borsboom"
        git config --global push.default simple
        git config --global core.autocrlf true
        git clone https://github.com/commercialhaskell/stack.git stack-release
        git clone https://github.com/borsboom/stack-installer.git

18. @@@ `stack exec -- gpg --import` (with the dev@fpcomplete.com secret key -- must be done using `stack exec` because that uses the right keyring for the embedded msys GPG)

## Setting up an ARM VM for releases

@@@ NOTE SCALEWAY INSTEAD, w/ ubuntu xenial.  use apt-get install -y llvm-3.X (3.9 for GHC 8.2, 3.7 for GHC 8.0)  then symlink opt-3.X to `opt` (e.g. `sudo ln -s opt-3.9 /usr/bin/opt`), and also switch to gold linker:

    update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.gold" 20
    update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.bfd" 10
    update-alternatives --config ld

    dd if=/dev/zero of=/swapfile1 bs=1024 count=4194304
    mkswap /swapfile1
    swapon /swapfile1
    echo '/swapfile1 none swap sw 0 0' >>/etc/fstab

    apt-get update && apt-get install -y unzip #@@@ AND OTHERS

    #@@@ gpg --import for the dev@fpcomplete.com key


These instructions assume the host system is running macOS. Some steps will vary
with a different host OS.

### Install qemu on host

    brew install qemu

### Install fuse-ext2

    brew install e2fsprogs m4 automake autoconf libtool && \
    git clone https://github.com/alperakcan/fuse-ext2.git && \
    cd fuse-ext2 && \

Add `m4_ifdef([AM_PROG_AR], [AM_PROG_AR])` to the `configure.ac` after
`m4_ifdef([AC_PROG_LIB],[AC_PROG_LIB],[m4_warn(portability,[Missing AC_PROJ_LIB])])`
line.

    PKG_CONFIG_PATH="$(brew --prefix e2fsprogs)/lib/pkgconfig" \
        CFLAGS="-idirafter/$(brew --prefix e2fsprogs)/include -idirafter/usr/local/include/osxfuse" \
        LDFLAGS="-L$(brew --prefix e2fsprogs)/lib" \
        ./configure

### Create VM and install Debian in it

    wget http://ftp.de.debian.org/debian/dists/jessie/main/installer-armhf/current/images/netboot/initrd.gz && \
    wget http://ftp.de.debian.org/debian/dists/jessie/main/installer-armhf/current/images/netboot/vmlinuz && \
    wget http://ftp.de.debian.org/debian/dists/jessie/main/installer-armhf/current/images/device-tree/vexpress-v2p-ca9.dtb && \
    qemu-img create -f raw armdisk.raw 15G && \
    qemu-system-arm -M vexpress-a9 -cpu cortex-a9 -kernel vmlinuz -initrd initrd.gz -sd armdisk.raw -append "root=/dev/mmcblk0p2" -m 1024M -redir tcp:2223::22 -dtb vexpress-v2p-ca9.dtb -append "console=ttyAMA0,115200" -serial stdio

Now the Debian installer will run. Don't use LVM for partitioning (it won't
boot), and add at least 4 GB swap during installation.

### Get boot files after install

Adjust the disk number `/dev/disk3` below to match the output from `hdiutil attach`.

    hdiutil attach -imagekey diskimage-class=CRawDiskImage -nomount armdisk.raw && \
    sudo mkdir -p /Volumes/debarm && \
    sudo fuse-ext2 /dev/disk3s1 /Volumes/debarm/ && \
    sleep 5 && \
    cp /Volumes/debarm/vmlinuz-3.16.0-4-armmp . && \
    cp /Volumes/debarm/initrd.img-3.16.0-4-armmp . && \
    sudo umount /Volumes/debarm && \
    hdiutil detach /dev/disk3

### Boot VM

Adjust `/dev/mmcblk0p3` below to the root partition you created during installation.

    qemu-system-arm -M vexpress-a9 -cpu cortex-a9 -kernel vmlinuz-3.16.0-4-armmp -initrd initrd.img-3.16.0-4-armmp -sd armdisk.raw -m 1024M -dtb vexpress-v2p-ca9.dtb -append "root=/dev/mmcblk0p3 console=ttyAMA0,115200" -serial stdio -redir tcp:2223::22

### Setup rest of system

Log onto the VM as root, then (replace `<<<USERNAME>>>` with the user you set up
during Debian installation):

    apt-get update && \
    apt-get install -y sudo && \
    adduser <<<USERNAME>>> sudo

Now you can SSH to the VM using `ssh -Ap 2223 <<<USERNAME>>>@localhost` and use `sudo` in
the shell.

### Install build tools and dependencies packages

    sudo apt-get install -y g++ gcc libc6-dev libffi-dev libgmp-dev make xz-utils zlib1g-dev git gnupg

### Install clang+llvm

NOTE: the Debian jessie `llvm` package does not work (executables built with it
just exit with "schedule: re-entered unsafely.").

The version of LLVM needed depends on the version of GHC you need.

#### GHC 8.0.2 (the standard for building Stack)

    wget http://llvm.org/releases/3.7.1/clang+llvm-3.7.1-armv7a-linux-gnueabihf.tar.xz && \
    sudo tar xvf clang+llvm-3.7.1-armv7a-linux-gnueabihf.tar.xz -C /opt

Run this now and add it to the `.profile`:

    export PATH="$HOME/.local/bin:/opt/clang+llvm-3.7.1-armv7a-linux-gnueabihf/bin:$PATH"

#### GHC 7.10.3

    wget http://llvm.org/releases/3.5.2/clang+llvm-3.5.2-armv7a-linux-gnueabihf.tar.xz && \
    sudo tar xvf clang+llvm-3.5.2-armv7a-linux-gnueabihf.tar.xz -C /opt

Run this now and add it to the `.profile`:

    export PATH="$HOME/.local/bin:/opt/clang+llvm-3.5.2-armv7a-linux-gnueabihf/bin:$PATH"

### Install Stack

#### Binary

Get an [existing `stack` binary](https://github.com/commercialhaskell/stack/releases)
and put it in `~/.local/bin`.

#### From source (using cabal-install):

    wget http://downloads.haskell.org/~ghc/7.10.3/ghc-7.10.3-armv7-deb8-linux.tar.xz && \
    tar xvf ghc-7.10.3-armv7-deb8-linux.tar.xz && \
    cd ghc-7.10.3 && \
    ./configure --prefix=/opt/ghc-7.10.3 && \
    sudo make install && \
    cd ..
    export PATH="/opt/ghc-7.10.3/bin:$PATH"
    wget https://www.haskell.org/cabal/release/cabal-install-1.24.0.0/cabal-install-1.24.0.0.tar.gz &&&&& \
    tar xvf cabal-install-1.24.0.0.tar.gz && \
    cd cabal-install-1.24.0.0 && \
    EXTRA_CONFIGURE_OPTS="" ./bootstrap.sh && \
    cd .. && \
    export PATH="$HOME/.cabal/bin:$PATH" && \
    cabal update

Edit `~/.cabal/config`, and set `executable-stripping: False` and
`library-stripping: False`.

    cabal unpack stack && \
    cd stack-* && \
    cabal install && \
    mv ~/.cabal/bin/stack ~/.local/bin

### Import GPG private key

Import the `dev@fpcomplete.com` (0x575159689BEFB442) GPG secret key

### Resources

  - http://mashu.github.io/2015/08/12/QEMU-Debian-armhf.html
  - https://www.aurel32.net/info/debian_arm_qemu.php
  - http://linuxdeveloper.blogspot.ca/2011/08/how-to-install-arm-debian-on-ubuntu.html
  - http://www.macworld.com/article/2855038/how-to-mount-and-manage-non-native-file-systems-in-os-x-with-fuse.html
  - https://github.com/alperakcan/fuse-ext2#mac-os
  - https://github.com/alperakcan/fuse-ext2/issues/31#issuecomment-214713801
  - https://github.com/alperakcan/fuse-ext2/issues/33#issuecomment-216758378
  - https://github.com/alperakcan/fuse-ext2/issues/32#issuecomment-216758019
  - http://osxdaily.com/2007/03/23/create-a-ram-disk-in-mac-os-x/

## Adding a new GHC version

  * Push new tag to our fork:

        git clone git@github.com:commercialhaskell/ghc.git
        cd ghc
        git remote add upstream git@github.com:ghc/ghc.git
        git fetch upstream
        git push origin ghc-X.Y.Z-release

  * [Publish a new Github release](https://github.com/commercialhaskell/ghc/releases/new)
    with tag `ghc-X.Y.Z-release` and same name.

  * Down all the relevant GHC bindists from https://www.haskell.org/ghc/download_ghc_X_Y_Z and upload them to the just-created Github release (see
    [stack-setup-2.yaml](https://github.com/fpco/stackage-content/blob/master/stack/stack-setup-2.yaml)
    for the ones we used in the last GHC release).

    In the case of macOS, repackage the `.xz` bindist as a `.bz2`, since macOS does
    not include `xz` by default or provide an easy way to install it.

    The script at `etc/scripts/mirror-ghc-bindists-to-github.sh` will help with
    this. See the comments within the script.
    [@@@ dan burton  has a script that does some of this too - https://gist.github.com/DanBurton/9d5655f64ab5d5f2a588e6fb809481fc   https://fpcomplete.slack.com/archives/D0ACX36BB/p1520536430000625]

  * Build any additional required bindists (see below for instructions)

      @@@ once stack-1.7 out which has fallbacks, might not need tinfo6 anymore but just ncurses6 (if all distros that have tinfo6 can be assumed to have ncurses6)
      @@@ used void linux to build with ncurses6, since other distros now include tinfo6

      * @@@ 32-bit/64-bit gmp4/centos67?
      * tinfo6 and tinfo6-nopie(`etc/vagrant/fedora-24-x86_64`) -- @@@ used by at least Arch, Gentoo/Sabayon
      * ncurses6-nopie (`etc/vagrant/arch-x86_64`) -- be sure to upgrade VM, last time it wasn't nopie.  see if we can ask @cocreature to build, he did the last one (https://github.com/fpco/stackage-content/pull/26)
  * [Edit stack-setup-2.yaml](https://github.com/fpco/stackage-content/edit/master/stack/stack-setup-2.yaml)
    and add the new bindists, pointing to the Github release version. Be sure to
    update the `content-length` and `sha1` values.


@@@ PATCH FOR TINFO6 `configure` FOR GENTOO
```
--- ../configure.ORIG 2017-12-27 16:05:40.509226151 +0000
+++ configure 2017-12-27 16:06:02.222226151 +0000
@@ -4715,6 +4715,23 @@
    fi
    rm -f conftest.c conftest.o conftest

+   # This patch seems to fix linking on Gentoo
+   { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether GCC supports --no-pie" >&5
+$as_echo_n "checking whether GCC supports --no-pie... " >&6; }
+   echo 'int main() { return 0; }' > conftest.c
+   # Some GCC versions only warn when passed an unrecognized flag.
+   if $CC --no-pie -x c /dev/null -dM -E > conftest.txt 2>&1 && ! grep -i unrecognized conftest.txt > /dev/null 2>&1; then
+       if test "$CONF_GCC_SUPPORTS_NO_PIE" = NO; then
+           CONF_GCC_LINKER_OPTS_STAGE2="$CONF_GCC_LINKER_OPTS_STAGE2 --no-pie"
+       fi
+       { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+   else
+       { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+   fi
+   rm -f conftest.c conftest.o conftest
+
 ac_ext=c
 ac_cpp='$CPP $CPPFLAGS'
 ac_compile='$CC -c $CFLAGS $CPPFLAGS conftest.$ac_ext >&5'
```

### Building GHC

@@@ check out https://github.com/bgamari/ghc-utils/blob/master/rel-eng/bin-release.sh, which is the script used to official bindists

On systems with a small `/tmp`, you should set TMP and TEMP to an alternate
location.

@@@ standardize on ubuntu 16.04 for builds without terminfo

Setup the system based on [these instructions](https://ghc.haskell.org/trac/ghc/wiki/Building/Preparation/Linux).  On Ubuntu (`docker run -ti --rm ubuntu:16.04`):

    apt-get update && apt-get install -y ghc alex happy make autoconf g++ git vim xz-utils automake libtool gcc libgmp-dev ncurses-dev libtinfo-dev python3

on Void Linux (`docker run -ti --rm voidlinux/voidlinux bash`):

    xbps-install -S curl gcc make xz ghc autoconf git vim automake gmp-devel ncurses-devel python3 cabal-install && \
    cabal update && \
    cabal install alex happy

For GHC >= 7.10.2, set the `GHC_VERSION` environment variable to the version to build:

  * `export GHC_VERSION=8.2.2`
  * `export GHC_VERSION=8.2.1`
  * `export GHC_VERSION=8.0.2`
  * `export GHC_VERSION=8.0.1`
  * `export GHC_VERSION=7.10.3a`
  * `export GHC_VERSION=7.10.2`

then, run (from [here](https://ghc.haskell.org/trac/ghc/wiki/Newcomers)):

@@@ should also patch 'configure' with gentoo --no-pie check (see below)

    git config --global url."git://github.com/ghc/packages-".insteadOf git://github.com/ghc/packages/ && \
    git clone -b ghc-${GHC_VERSION}-release --recursive git://github.com/ghc/ghc ghc-${GHC_VERSION} && \
    cd ghc-${GHC_VERSION}/ && \
    cp mk/build.mk.sample mk/build.mk && \
    sed -i 's/^#BuildFlavour *= *perf$/BuildFlavour = perf/' mk/build.mk && \
    ./boot && \
    ./configure --enable-tarballs-autodownload && \
    sed -i 's/^TAR_COMP *= *bzip2$/TAR_COMP = xz/' mk/config.mk && \
    make -j$(cat /proc/cpuinfo|grep processor|wc -l) && \
    make binary-dist

GHC 7.8.4 is slightly different:

    export GHC_VERSION=7.8.4 && \
    git config --global url."git://github.com/ghc/packages-".insteadOf git://github.com/ghc/packages/ && \
    git clone -b ghc-${GHC_VERSION}-release --recursive git://github.com/ghc/ghc ghc-${GHC_VERSION} && \
    cd ghc-${GHC_VERSION}/ && \
    ./sync-all --extra --nofib -r git://git.haskell.org get -b ghc-7.8 && \
    cp mk/build.mk.sample mk/build.mk && \
    sed -i 's/^#BuildFlavour *= *perf$/BuildFlavour = perf/' mk/build.mk && \
    perl boot && \
    ./configure && \
    sed -i 's/^TAR_COMP *= *bzip2$/TAR_COMP = xz/' mk/config.mk && \
    make -j$(cat /proc/cpuinfo|grep processor|wc -l) && \
    make binary-dist








# @@@ tinfo/ncurses/nopie bindist stuff

docker run -ti --name stack-arch base/archlinux
pacman -Syu make gcc git
curl -sSL https://get.haskellstack.org/ |sh
stack setup
stack new test
cd test
stack build
stack exec test-exe



@@@ stack ghc builds: https://docs.google.com/spreadsheets/d/16SkXJkPkK0QoGLmNlDdA82rrurSBzAIqgxbE9LhPu-4/edit#gid=0

@@@ issue to discuss using ghc bindist with `WITH_TERMINFO=NO` (`sed -i 's/^WITH_TERMINFO=YES$/WITH_TERMINFO=NO/' mk/config.mk`)
@@@ issue to have 'configure' patches "inline" in stack-setup-2.yaml instead of needing to patch GHC bindist
@@@ issue to have fallback from tinfo6 to ncurses6 to ncurses5 (or vice-versa)
@@@ issue to remove check for `nopie` since it's fundamentally broken (this may cause old GHC versions to fail on some old distro versions, but we could patch those bindists to work if needed), and also remove support for `configure-env` in stack-setup-2.yaml
@@@ adjust djustments to https://github.com/commercialhaskell/stack/blob/stable/doc/faq.md#i-get-strange-ld-errors-about-recompiling-with--fpic
@@@ come back to https://github.com/commercialhaskell/stack/issues/3518 and merge if OK


@@@ proposal
- if tinfo6-pie build exists use it, then fall back to tinfo6, then ncurses6-nopie, then ncurses6, then nopie, and finally default build
- for future ghcs, only add default build with a 'USE_TERMINFO=NO' GHC bindist
- eventually drop checks for nopie, tinfo6, and ncurses6 builds


### Debian stretch (standard -no-pie)

docker run -ti --name stack-debian-stretch-tmp debian:stretch
apt-get update && apt-get install -y curl vim less git

### Arch (tinfo6 -no-pie)

docker run -ti --name stack-arch-tmp base/archlinux
pacman -Syu make gcc git

### Sabayon/Gentoo (tinfo6 --no-pie)

docker run -ti --name stack-gentoo-tmp sabayon/base-amd64 bash
equo install git gcc make vim

### Void (ncurses6 -no-pie)

docker run -ti --name stack-void-tmp voidlinux/voidlinux bash
xbps-install -S curl gcc make xz git vim perl gmp-devel

### Ubuntu 16.04 (standard)

docker run -ti --name stack-ubuntu1604-tmp ubuntu:16.04
apt-get update && apt-get install -y curl vim less git

### Fedora 27

docker run -ti --name stack-fedora27-tmp fedora:27 bash
dnf install -y git

### CentOS 7

docker run -ti  --name stack-centos7-tmp centos:7
yum install -y git

### General

curl https://get.haskellstack.org/ |sh && \
cd $HOME && \
git clone https://github.com/borsboom/stack-test-nopie.git

#@@@ RESOLVER=lts-6.35
#@@@ RESOLVER=lts-7.24
#@@@ RESOLVER=lts-3.22
RESOLVER=lts-2.22
STACKAGE_CONTENT_BRANCH=more-nopie-bindists
cd ~/stack-test-nopie && \
rm -rf ~/.stack .stack-work && \
stack --resolver=${RESOLVER} setup --setup-info-yaml=https://raw.githubusercontent.com/fpco/stackage-content/${STACKAGE_CONTENT_BRANCH}/stack/stack-setup-2.yaml && \
stack --resolver=${RESOLVER} test

# Confirm that correct C compiler link flags set in settings file

make-patched-bindists.sh:

```
#!/usr/bin/env bash
set -xeu -o pipefail
GHC_VERSION=7.10.1
BINDISTS="linux32:ghc-7.10.1-i386-unknown-linux-deb7 linux64:ghc-7.10.1-x86_64-unknown-linux-deb7"
PATCH_NAME=patch1
rm -f setup-info-${GHC_VERSION}-${PATCH_NAME}.yaml
#@@@: should just take each one on command-line and run script multipel times rather that iterating
for BINDIST in $BINDISTS; do
  BINDIST_KEY=${BINDIST%%:*}
  BINDIST_NAME=${BINDIST##*:}
  if [[ ! -s ${BINDIST_NAME}.tar.xz ]]; then
    curl -L https://github.com/commercialhaskell/ghc/releases/download/ghc-${GHC_VERSION}-release/${BINDIST_NAME}.tar.xz >${BINDIST_NAME}.tar.xz.tmp
    mv ${BINDIST_NAME}.tar.xz.tmp ${BINDIST_NAME}.tar.xz
  fi
  if [[ ! -s ${BINDIST_NAME}-${PATCH_NAME}.tar.xz ]]; then
    rm -rf ghc-${GHC_VERSION}
    tar xJvf ${BINDIST_NAME}.tar.xz
    patch ghc-${GHC_VERSION}/configure <configure-${GHC_VERSION}.patch
    tar cJvf ${BINDIST_NAME}-${PATCH_NAME}.tar.xz.tmp ghc-${GHC_VERSION} --owner=0 --group=0
    mv ${BINDIST_NAME}-${PATCH_NAME}.tar.xz.tmp ${BINDIST_NAME}-${PATCH_NAME}.tar.xz
  fi
  if [[ ! -f ${BINDIST_NAME}-${PATCH_NAME}.tar.xz.upload ]]; then
    github-release upload --file ${BINDIST_NAME}-${PATCH_NAME}.tar.xz --owner commercialhaskell --repo ghc --tag ghc-${GHC_VERSION}-release --token $GITHUB_AUTH_TOKEN --name ${BINDIST_NAME}-${PATCH_NAME}.tar.xz
    touch ${BINDIST_NAME}-${PATCH_NAME}.tar.xz.upload
  fi
  tee -a setup-info-${GHC_VERSION}-${PATCH_NAME}.yaml <<EOF
    ${BINDIST_KEY}-nopie:
        ${GHC_VERSION}:
            url: "https://github.com/commercialhaskell/ghc/releases/download/ghc-${GHC_VERSION}-release/${BINDIST_NAME}-${PATCH_NAME}.tar.xz"
            content-length: $(ls -l ${BINDIST_NAME}-${PATCH_NAME}.tar.xz|awk '{print $5}')
            sha1: $(sha1sum ${BINDIST_NAME}-${PATCH_NAME}.tar.xz|awk '{print $1}')
EOF
done
```


configure-7.8.4.patch:

```
--- configure.orig  2018-02-02 14:10:19.773144150 +0000
+++ configure 2018-02-02 14:11:19.180373715 +0000
@@ -4460,6 +4460,33 @@
 GccVersion=$fp_cv_gcc_version


+   # This patch seems to fix linking when GCC has PIE enabled by default
+   { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether GCC supports -no-pie" >&5
+$as_echo_n "checking whether GCC supports -no-pie... " >&6; }
+   echo 'int main() { return 0; }' > conftest.c
+   # Some GCC versions only warn when passed an unrecognized flag.
+   if $CC -no-pie -x c /dev/null -dM -E > conftest.txt 2>&1 && ! grep -i unrecognized conftest.txt > /dev/null 2>&1; then
+       CONF_GCC_LINKER_OPTS_STAGE2="$CONF_GCC_LINKER_OPTS_STAGE2 -no-pie"
+       { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+   else
+       { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+       { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether GCC supports --no-pie" >&5
+    $as_echo_n "checking whether GCC supports --no-pie... " >&6; }
+       echo 'int main() { return 0; }' > conftest.c
+       # Some GCC versions only warn when passed an unrecognized flag.
+       if $CC --no-pie -x c /dev/null -dM -E > conftest.txt 2>&1 && ! grep -i unrecognized conftest.txt > /dev/null 2>&1; then
+           CONF_GCC_LINKER_OPTS_STAGE2="$CONF_GCC_LINKER_OPTS_STAGE2 --no-pie"
+           { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+    $as_echo "yes" >&6; }
+       else
+           { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+    $as_echo "no" >&6; }
+       fi
+       rm -f conftest.c conftest.o conftest
+   fi
+   rm -f conftest.c conftest.o conftest


 ac_ext=c
```

configure-7.10.1.patch:

```
--- configure.orig  2018-02-02 05:40:55.120168597 -0800
+++ configure 2018-02-02 05:42:00.261722166 -0800
@@ -5142,6 +5142,33 @@
 GccVersion=$fp_cv_gcc_version


+   # This patch seems to fix linking when GCC has PIE enabled by default
+   { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether GCC supports -no-pie" >&5
+$as_echo_n "checking whether GCC supports -no-pie... " >&6; }
+   echo 'int main() { return 0; }' > conftest.c
+   # Some GCC versions only warn when passed an unrecognized flag.
+   if $CC -no-pie -x c /dev/null -dM -E > conftest.txt 2>&1 && ! grep -i unrecognized conftest.txt > /dev/null 2>&1; then
+       CONF_GCC_LINKER_OPTS_STAGE2="$CONF_GCC_LINKER_OPTS_STAGE2 -no-pie"
+       { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+   else
+       { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+       { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether GCC supports --no-pie" >&5
+    $as_echo_n "checking whether GCC supports --no-pie... " >&6; }
+       echo 'int main() { return 0; }' > conftest.c
+       # Some GCC versions only warn when passed an unrecognized flag.
+       if $CC --no-pie -x c /dev/null -dM -E > conftest.txt 2>&1 && ! grep -i unrecognized conftest.txt > /dev/null 2>&1; then
+           CONF_GCC_LINKER_OPTS_STAGE2="$CONF_GCC_LINKER_OPTS_STAGE2 --no-pie"
+           { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+    $as_echo "yes" >&6; }
+       else
+           { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+    $as_echo "no" >&6; }
+       fi
+       rm -f conftest.c conftest.o conftest
+   fi
+   rm -f conftest.c conftest.o conftest


 ac_ext=c
```


configure-7.10.2.patch

```
--- configure.orig  2018-02-02 05:40:55.120168597 -0800
+++ configure 2018-02-02 05:42:00.261722166 -0800
@@ -5142,6 +5142,33 @@
 GccVersion=$fp_cv_gcc_version


+   # This patch seems to fix linking when GCC has PIE enabled by default
+   { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether GCC supports -no-pie" >&5
+$as_echo_n "checking whether GCC supports -no-pie... " >&6; }
+   echo 'int main() { return 0; }' > conftest.c
+   # Some GCC versions only warn when passed an unrecognized flag.
+   if $CC -no-pie -x c /dev/null -dM -E > conftest.txt 2>&1 && ! grep -i unrecognized conftest.txt > /dev/null 2>&1; then
+       CONF_GCC_LINKER_OPTS_STAGE2="$CONF_GCC_LINKER_OPTS_STAGE2 -no-pie"
+       { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+   else
+       { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+       { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether GCC supports --no-pie" >&5
+    $as_echo_n "checking whether GCC supports --no-pie... " >&6; }
+       echo 'int main() { return 0; }' > conftest.c
+       # Some GCC versions only warn when passed an unrecognized flag.
+       if $CC --no-pie -x c /dev/null -dM -E > conftest.txt 2>&1 && ! grep -i unrecognized conftest.txt > /dev/null 2>&1; then
+           CONF_GCC_LINKER_OPTS_STAGE2="$CONF_GCC_LINKER_OPTS_STAGE2 --no-pie"
+           { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+    $as_echo "yes" >&6; }
+       else
+           { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+    $as_echo "no" >&6; }
+       fi
+       rm -f conftest.c conftest.o conftest
+   fi
+   rm -f conftest.c conftest.o conftest


 ac_ext=c
```

configure-7.10.3.patch:

```
--- configure.orig  2018-02-02 05:40:55.120168597 -0800
+++ configure 2018-02-02 05:42:00.261722166 -0800
@@ -5142,6 +5142,33 @@
 GccVersion=$fp_cv_gcc_version


+   # This patch seems to fix linking when GCC has PIE enabled by default
+   { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether GCC supports -no-pie" >&5
+$as_echo_n "checking whether GCC supports -no-pie... " >&6; }
+   echo 'int main() { return 0; }' > conftest.c
+   # Some GCC versions only warn when passed an unrecognized flag.
+   if $CC -no-pie -x c /dev/null -dM -E > conftest.txt 2>&1 && ! grep -i unrecognized conftest.txt > /dev/null 2>&1; then
+       CONF_GCC_LINKER_OPTS_STAGE2="$CONF_GCC_LINKER_OPTS_STAGE2 -no-pie"
+       { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+   else
+       { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+       { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether GCC supports --no-pie" >&5
+    $as_echo_n "checking whether GCC supports --no-pie... " >&6; }
+       echo 'int main() { return 0; }' > conftest.c
+       # Some GCC versions only warn when passed an unrecognized flag.
+       if $CC --no-pie -x c /dev/null -dM -E > conftest.txt 2>&1 && ! grep -i unrecognized conftest.txt > /dev/null 2>&1; then
+           CONF_GCC_LINKER_OPTS_STAGE2="$CONF_GCC_LINKER_OPTS_STAGE2 --no-pie"
+           { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+    $as_echo "yes" >&6; }
+       else
+           { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+    $as_echo "no" >&6; }
+       fi
+       rm -f conftest.c conftest.o conftest
+   fi
+   rm -f conftest.c conftest.o conftest


 ac_ext=c
```

 configure-8.0.1.patch:

```
--- ../configure-8.0.1.orig  2018-02-01 17:51:51.577431743 +0000
+++ configure 2018-02-01 17:53:12.374095626 +0000
@@ -5259,20 +5259,47 @@
 if test "$fp_num1" -lt "$fp_num2"; then :
   GccLT46=YES
 fi

 fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $fp_cv_gcc_version" >&5
 $as_echo "$fp_cv_gcc_version" >&6; }
 GccVersion=$fp_cv_gcc_version


+   # This patch seems to fix linking when GCC has PIE enabled by default
+   { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether GCC supports -no-pie" >&5
+$as_echo_n "checking whether GCC supports -no-pie... " >&6; }
+   echo 'int main() { return 0; }' > conftest.c
+   # Some GCC versions only warn when passed an unrecognized flag.
+   if $CC -no-pie -x c /dev/null -dM -E > conftest.txt 2>&1 && ! grep -i unrecognized conftest.txt > /dev/null 2>&1; then
+       CONF_GCC_LINKER_OPTS_STAGE2="$CONF_GCC_LINKER_OPTS_STAGE2 -no-pie"
+       { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+   else
+       { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+       { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether GCC supports --no-pie" >&5
+    $as_echo_n "checking whether GCC supports --no-pie... " >&6; }
+       echo 'int main() { return 0; }' > conftest.c
+       # Some GCC versions only warn when passed an unrecognized flag.
+       if $CC --no-pie -x c /dev/null -dM -E > conftest.txt 2>&1 && ! grep -i unrecognized conftest.txt > /dev/null 2>&1; then
+           CONF_GCC_LINKER_OPTS_STAGE2="$CONF_GCC_LINKER_OPTS_STAGE2 --no-pie"
+           { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+    $as_echo "yes" >&6; }
+       else
+           { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+    $as_echo "no" >&6; }
+       fi
+       rm -f conftest.c conftest.o conftest
+   fi
+   rm -f conftest.c conftest.o conftest


 ac_ext=c
 ac_cpp='$CPP $CPPFLAGS'
 ac_compile='$CC -c $CFLAGS $CPPFLAGS conftest.$ac_ext >&5'
 ac_link='$CC -o conftest$ac_exeext $CFLAGS $CPPFLAGS $LDFLAGS conftest.$ac_ext $LIBS >&5'
 ac_compiler_gnu=$ac_cv_c_compiler_gnu
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking how to run the C preprocessor" >&5
 $as_echo_n "checking how to run the C preprocessor... " >&6; }
 # On Suns, sometimes $CPP names a directory.
```
