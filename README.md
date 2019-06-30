# Nubs

A Nub is a simple Git repository rendered as a single HTML page: each file is
displayed one after the other. The top of the page can optionally contain HTML
generated from the repository by a build script. This is for instance the
default when there is a README.md file: the Markdown is converted to HTML with
Pandoc.

nubs-bash is a Nix expression (`nubs.nix`) that builds an HTML representation
of a Git repository.

This project can also be seen as a collection of small bits of HTML pieces to
generate static pages.


## Organization

There are three Bash scripts that can be either called manually from the
command-line or called by the HTTP backend:

- A script to create a new Git repository
- A script to commit a new file or changes to an existing file to a repository
- A script to generate static HTML files from a repository

There is a small Haskell program to receive HTTP POSTs to save files.

There is a HTML template used by the second script above.

There is a helper Haskell program to generate the above template. (The reason
is to let the Haskell code to generate HTML be reused in other projects.)


## Installing

The scripts in the `bin/` directory expect an existing directory called
`/nubs`. It can be created as follow:

```
$ sudo mkdir /nubs
$ sudo chown $USER:users /nubs
```


## Running

To build this repository, invoke `nubs.nix` as follow:

```
$ nix-build nubs.nix -A nubs.site -I repository=nubs-bash.json
```

Replace the `repository` variable by another repository as needed (see examples
below).

In addition of the main attribute `nubs.site`, which is the "whole" result,
fragments can be built individually.

- `nubs.top` is the "rendered" HTML fragment at the top of the page (but below
  the navigation bar). This is for instance a `README.md` file processed by
  Pandoc.
- `nubs.index` is the main page fragment without the HTML prologue and
  epilogue. It starts with `nubs.top`.
- `nubs.site` is the full static site directory.


## Examples

Observe the `result` after each of those commands:

```
$ nix-build nubs.nix -A nubs.top -I repository=nubs-empty.json
$ nix-build nubs.nix -A nubs.top -I repository=nubs-readme.json
$ nix-build nubs.nix -A nubs.top -I repository=nubs-default.json
```

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
