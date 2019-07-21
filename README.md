# Blank

Blank manages small Git repositories to render them to HTML and edit them
through HTTP.

It is currently a rough proof-of-concept.

Each Git repository is rendered as a single HTML page: each file within the
repository are displayed one after the other. The top of the page can
optionally contain HTML generated from the repository by a build script. This
is for instance the default when there is a README.md file: the Markdown is
converted to HTML with Pandoc.

Blank provides a Nix expression (`blank.nix`) that builds the HTML
representation of a Git repository.

Blank can also be seen as a collection of small bits of HTML pieces to generate
static pages.


## Organization

There are four Bash scripts that can be either called manually from the
command-line or called by the HTTP backend:

- A script to create a new Git repository
- A script to commit a new file or changes to an existing file to a repository
- A script to generate static HTML files from a repository
- A script to read a (raw) file from a Git repository

There is a small Haskell program to receive HTTP POSTs to save files, and GET
to return the raw files.

There is a HTML template used by the second script above.

There is a helper Haskell program to generate the above template. (The reason
is to let the Haskell code to generate HTML be reused in other projects.)


## Installing

The scripts in the `bin/` directory expect an existing directory called
`/blank`. It can be created as follow (assuming we run the backend with
`$USER`):

```
$ sudo mkdir /blank
$ sudo chown $USER:users /nubs
```


## Running

To build a repository in `/blank`, invoke `blank.nix` as follow:

```
$ nix-build blank.nix -A blank.site -I repository=blank.json
```

Replace the `repository` variable by another repository as needed (see examples
below).

In addition of the main attribute `blank.site`, which is the "whole" result,
fragments can be built individually.

- `blank.top` is the "rendered" HTML fragment at the top of the page (but below
  the navigation bar). This is for instance a `README.md` file processed by
  Pandoc.
- `blank.index` is the main page fragment without the HTML prologue and
  epilogue. It starts with `blank.top`.
- `blank.site` is the full static site directory.


## Examples

Observe the `result` symlink after each of those commands:

```
$ nix-build blank.nix -A blank.top -I repository=blank-empty.json
$ nix-build blank.nix -A blank.top -I repository=blank-readme.json
$ nix-build blank.nix -A blank.top -I repository=blank-default.json
```

To create an example repository and demonstrate the scripts in `bin/`, you can
call the `spawn.sh` script:

```
$ ./spawn.sh
```


## using individual scripts

Creating a new repository within `/blank` can be done with `blank-init`:

```
$ bin/blank-init blank.git
Initialized empty Git repository in /blank/blank.git/
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

In particular, testing if a "blank" attribute is defined:

```
nix-instantiate --expr --eval \
  'builtins.elem "blank" (builtins.attrNames (import ./default.nix))'
```

I'd like to list the values used to fill the angle-racket "holes" (what's the
correct word in Nix parlance ?).

Tests should be added. e.g. a nice error message should be displayed when the
web page saves to a non-existing repository.

Instead of saving to a Git repository, another handler should be written to
save to a S3 bucket.
