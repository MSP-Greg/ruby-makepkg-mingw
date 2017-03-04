## ruby-makepkg-mingw

Current Build Data - `ruby 2.5.0dev (2017-03-04 trunk 57768) [x64-mingw32]`

### mingw/msys2 package builders for Ruby build dependencies

### Important Notes

All the included scripts use the --skippgpcheck flag, which bypasses the pgp checking.  All files are checked for SHA256.

It is assumed that you are familiar with using the msys2/mingw shell and path commands.

### Purpose

This repo is for initial development and testing of msys2/mingw2 packages for Ruby builds. In particular, to work with [larskanis/rubyinstaller2](https://github.com/larskanis/rubyinstaller2).

Once the packages/code is well tested, both will hopefully be accepted into the msys2/mingw ecosystem, and there won't be any further active development, except if new package versions are needed.

I've tested these packages with builds of Ruby trunk, they need to be tested with previous versions.  If they don't work, additional package versions may be needed.

### Description

Three Ruby dependencies are provided, gdbm, libyaml, and openssl.

gdbm is version 1.10, libyaml is 0.1.7, openssl is 1.1.0e.

### Creating the packages

Three scripts are provided for creating the packages:
```
ruby_make_all - creates 32 bit and 64 bit packages
ruby_make_32  - creates 32 bit packages
ruby_make_64  - creates 64 bit packages
```

From the mingw64 shell, run them with a full path.  On my system, the command is 
```
/d/GitHub/ruby-makepkg-mingw/ruby_make_all
```

Building all six versions may take quite a while (30+ minutes).  If you're building
with Windows, you might want to disable any firewall security, as the OpenSSL tests will hit it.

Test result files are in the test_results folder.  Your results should match.
Please check before adding the packages.

If you decide to re-run the creation scripts, I might suggest deleting the `pkg`
and `src` folders first.

### Installing the packages

Likewise, three scripts are provided:

```
ruby_pacman_all
ruby_pacman_32
ruby_pacman_64
```

As above, run them with a full path.  You may need to confirm each packages' installation.

### `mingw-w64-ruby` Folder

This folder contains the current PBKBUILD and patch files I'm using for building
the Ruby trunk branch.

### `ruby_logs` Folder

This contains two folders, 'Full' and 'Summary'.  'Full' contains all four build
logs (prepare, build, check, and package).  'Summary' contains the irregular info
from build and check.

### My build environment

For reasons I won't go into, I have often installed build tools and regularly
changing files on my D: drive.  Hence, mysy2 and my repos are on D:.  My OS and
'normal apps' are on C:, along with my temp folder.  I normally use Windows as a
standard user.  Hence, some of the test failures / errors are due to this.
