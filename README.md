# Simple Nubs in Bash

A Nub is a simple Git repository rendered as a single HTML page: each file is
displayed one after the other. The top of the page can optionally contain HTML
generated from the repository by a build script. This is for instance the
default when there is a README.md file: the Markdown is converted to HTML with
Pandoc.


## Installing

The scripts in the `bin/` directory expect an existing directory called
`/nubs`. It can be created as follow:

```
$ sudo mkdir /nubs
$ sudo chown $USER:users /nubs
```


## Example

To create an example Nub and demonstrate the scripts in `bin/`, you can call
the `spawn.sh` script:

```
$ ./spawn.sh
```


## Notes

I'd like to have a release.nix file that does the same as the default.nix one
but fixes the versions (i.e. angle-bracket "holes").

I'd like to enumerate the attributes of that default.nix or release.nix files,
and whether they can be built (nix-build -A) or just evaluated (nix-instantiate
--eval --strict -A).

Listing attributes can be done with

```
nix-instantiate --eval --expr 'builtins.attrNames (import ./default.nix)'
```

In particular, testing if a "nubs" attribute is defined:

```
nix-instantiate --expr --eval \
  'builtins.elem "nubs" (builtins.attrNames (import ./default.nix))'
```

I'd like to list the values used to fill the angle-racket "holes" (what's the
correct word in Nix parlance ?).

Tests should be added. e.g. a nice error message should be displayed when the
web page saves to a non-existing repository.

Instead of saving to a Git repository, another handler should be written to
save to a S3 bucket.
