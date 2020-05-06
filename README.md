# Blank

Blank manages small Git repositories to render them to HTML and edit them
through HTTP.

It is currently a rough proof-of-concept.

By default, each Git repository is rendered as a single HTML page: files within
the repository are displayed one after the other. The top of the page can
optionally contain HTML generated from the repository by a build script. This
is for instance the default when there is a README.md file: the Markdown is
converted to HTML with Pandoc.

Blank provides a Nix expression (`default.nix`) that builds the HTML
representation of a Git repository.

Blank can also be seen as a collection of small bits of HTML pieces to generate
static pages.

TODO: Blank re-uses the bits of HTML pieces from the design-system repository
to generate static pages.


## Organization

There are a few Bash scripts that can be either called manually from the
command-line or called by the HTTP backend:

- `blank-init`: a script to create a new empty Git repository,
- `blank-write-file`: a script to commit a new file or changes to an existing
  file to a repository,
- `blank-generate`: a script to generate static HTML files from a repository,
- `blank-read-file`: a script to read a (raw) file from a Git repository,
- `blank-spawn`: a helper script to generate example repositories,
- `blank-log`: a helper script to run `git log`.

The HTTP backend, `blank-server.hs`, is a small Haskell program to receive HTTP
`POST`s at `/edit/save` to save files, and `GET`s at
`/raw/:repository/:filename` to return the raw files.

There is a HTML template used by the second script above.

There is a helper Haskell program to generate the above template. (The reason
is to let the Haskell code used to generate HTML be reused in other projects.)

There is a Nix script, `default.nix`, that is used by `blank-generate`.


## Installing

The scripts in the `bin/` directory expect an existing directory called
`/blank`. It can be created as follow (assuming we run the backend with
`$USER`):

```
$ sudo mkdir /blank
$ sudo chown $USER:users /blank
```


## Using the `default.nix` Nix expression

To build a repository in `/blank/repos`, invoke `default.nix` as follow:

```
$ nix-build -A blank.site -I repository=examples/blank-empty.json
```

Replace the `repository` variable by another repository as needed (see examples
below).

The `.json` files were created with:

```
$ nix-prefetch-git --quiet --leave-dotGit /blank/REPO.git > blank-REPO.json
```

In addition of the main attribute `blank.site`, which is the "whole" result,
fragments can be built individually.

- `blank.top` is the "rendered" HTML fragment at the top of the page (but below
  the navigation bar). This is for instance a `README.md` file processed by
  Pandoc.
- `blank.index` is the main page fragment without the HTML prologue and
  epilogue. It starts with `blank.top`.
- `blank.site` is the full static site directory.


### Examples

Example `.json` files are given in the `examples/` directory. They work with
example repositories that can be created with the corresponding `spawn.sh`
scripts, also in the `examples/` directory.

For convenience, all the example repositories can be generated with:

```
$ bin/blank-spawn
```

Observe the `result` symlink after each of those commands:

```
$ nix-build -A blank.top -I repository=examples/blank-empty.json
$ nix-build -A blank.top -I repository=examples/blank-readme.json
$ nix-build -A blank.top -I repository=examples/blank-default.json
$ nix-build -A blank.top -I repository=examples/blank-pages.json
```


## Using individual scripts

Creating a new repository within `/blank` can be done with `blank-init`:

```
$ bin/blank-init blank
Initialized empty Git repository in /blank/blank.git/
```

Adding a file (or adding its modifications) to an existing repository is done
with `blank-write-file`:

```
$ cat README.md | bin/blank-write-file blank README.md
```

Generating a complete static site for all the repositories (including an index
page) can be done with `blank-generate`:

```
$ bin/blank-generate --all
```

Note: Running `blank-generate` on an empty repository will generate an error
page.

Reading a file:

```
$ bin/blank-read-file blank-readme README.md
```


## Notes

I'd like to have a release.nix file that does the same as the derivation.nix
one but fixes the versions (i.e. angle-bracket "holes").

I'd like to enumerate the attributes of that derivation.nix or release.nix
files, and whether they can be built (nix-build -A) or just evaluated
(nix-instantiate --eval --strict -A).

Listing attributes can be done with

```
nix-instantiate --eval --expr 'builtins.attrNames (import ./derivation.nix)'
```

In particular, testing if a "blank" attribute is defined:

```
nix-instantiate --expr --eval \
  'builtins.elem "blank" (builtins.attrNames (import ./derivation.nix))'
```

I'd like to list the values used to fill the angle-bracket "holes" (what's the
correct word in Nix parlance ?).

Tests should be added. E.g. a nice error message should be displayed when the
web page saves to a non-existing repository.

Instead of saving to a Git repository, another handler should be written to
save to a S3 bucket.
