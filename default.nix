let
  # When using a pinned nixpkgs here, unpacking the tarball in a runvm.sh VM
  # takes too much memory and disk. Instead, care should be taken to build
  # the VM with the correct nix.nixPath option.
  pkgs = import <nixpkgs> {};

  fix = f: let x = f x; in x;
  withOverrides = overrides: f: self: f self //
    (if builtins.isFunction overrides then overrides self else overrides);
  overrideable = f: fix f //
    { _overrides = overrides: overrideable (withOverrides overrides f); };

  repository-version = pkgs.lib.importJSON <repository>;
  repository = pkgs.fetchgit {
    # Ugly string conversion to path.
    url = /. + ("/" + repository-version.url);
    inherit (repository-version) rev sha256;
    leaveDotGit = true; # There seems to be a risk of this feature being
                        # removed because it can be non-deterministic.
  };
  repo-basename=pkgs.lib.strings.removePrefix "/var/lib/blank/repos/"
    repository-version.url;

  # Default values for the "blank" attribute (i.e. for when
  # a default.nix file is not present or doesn't contain a
  # "blank" attribute, or some sub-attribute).
  defaults = overrideable (self: with self; {

    # The default "top" attribute is a Pandoc-rendered
    # README.md file if present.
    top = pkgs.runCommand "top.html" {} ''
      if [[ -f ${repository}/README.md ]] ; then
        echo '<!-- README.md file. -->' > $out
        ${pkgs.pandoc}/bin/pandoc ${repository}/README.md >> $out
      else
        echo 'No README.md file.' > $out
      fi
    '';

    # The "overview" attribute shows Git information and content
    # as one page. It can be displayed after "top", on the same
    # page, or on its own page.
    overview = pkgs.runCommand "overview.html" { buildInputs = [ pkgs.git ]; } ''
      REPO_NAME=$(echo "${pkgs.lib.strings.removeSuffix ".git" repo-basename}")

      mkdir _site

      echo ${repository} > content.tmp1
      echo "<br /><br />" >> content.tmp1
      echo "show-ref -s fetchgit" >> content.tmp1
      echo "<code><pre>" >> content.tmp1
      git --git-dir=${repository}/.git show-ref -s fetchgit >> content.tmp1
      echo "</pre></code>" >> content.tmp1
      echo "<br />" >> content.tmp1
      cat content.tmp1 >> _site/overview.html

      echo "ls-tree fetchgit --long" > content.tmp2
      echo "<code><pre>" >> content.tmp2
      git --git-dir=${repository}/.git ls-tree fetchgit --long >> content.tmp2
      echo "</pre></code>" >> content.tmp2
      echo "<br />" >> content.tmp2
      cat content.tmp2 >> _site/overview.html

      i=0
      git --git-dir=${repository}/.git ls-tree fetchgit --name-only | \
        while read -r line ; do
          i=$((i + 1))
          echo "<form method=post action=/edit/save onsubmit='this.content.value=document.getElementById(\"c$i\").innerHTML;'>" > content.tmp3
          echo "show fetchgit:$line " >> content.tmp3
          echo "<input type=submit value=Save class=button-as-link />" >> content.tmp3
          echo "<input type=hidden name=repository value=$REPO_NAME />" >> content.tmp3
          echo "<input type=hidden name=filename value=$line />" >> content.tmp3
          echo "<input type=hidden name=content />" >> content.tmp3
          echo "<code><pre id=c$i contenteditable=true spellcheck=false>" >> content.tmp3
          git --git-dir=${repository}/.git show fetchgit:"$line" >> content.tmp3
          echo "</pre></code>" >> content.tmp3
          echo "</form>" >> content.tmp3
          echo "<br />" >> content.tmp3
          cat content.tmp3 >> _site/overview.html
        done

      cp _site/overview.html $out
    '';

    # The default "index" attribute is the main HTML page.
    # Normally it is not overridden.
    index = pkgs.runCommand "index.html" { buildInputs = [ pkgs.git ]; } ''
      mkdir _site
      cat ${top} >> _site/index.html
      echo "<hr />" >> _site/index.html
      cat ${overview} >> _site/index.html
      cp _site/index.html $out
    '';

    # Pages is an additional list of directories than can be included in the site.
    # By default it is empty.
    pages = [];

    # By default, the Git repository metadata and editable files are on
    # a separate page.
    separate-overview = true;

    site = pkgs.runCommand "site" {} ''
      SEPARATE_OVERVIEW="$(echo ${if separate-overview then "1" else ""})"

      mkdir _site

      cat ${templates/begin.html} > _site/index.html
      cat ${top} >> _site/index.html
      if [[ -n $SEPARATE_OVERVIEW ]] ; then
        cat ${templates/begin.html} > _site/overview.html
        cat ${overview} >> _site/overview.html
        echo "<hr />" >> _site/overview.html
        echo "<a href=\"index.html\">view</a>" >> _site/overview.html
        cat ${templates/end.html} >> _site/overview.html

        echo "<hr />" >> _site/index.html
        echo "<a href=\"overview.html\">edit</a>" >> _site/index.html
      else
        echo "<hr />" >> _site/index.html
        cat ${overview} >> _site/index.html
      fi
      cat ${templates/end.html} >> _site/index.html

      for i in \
        ${pkgs.lib.strings.concatStrings (pkgs.lib.strings.intersperse " " pages)} ; \
        do cp -r $i/* _site/ ; done
      cp -r _site $out
    '';

  });

  # I don't know how to test if a file exists without
  # resorting to a shell script, and I can import default.nix
  # below only if it exists within the repository.
  wrapper = pkgs.runCommand "wrapper.nix" {} ''
    if [[ -f ${repository}/default.nix ]] ; then
      echo import ${repository}/default.nix > $out
    else
      echo '{}' > $out
    fi
  '';

  # The user-defined default.nix, or an empty one.
  default = import wrapper;

  # Default blank attributes, shadowed by the user-defined ones.
  blank = if (default ? "blank") then defaults._overrides default.blank else defaults;
in
  default // { inherit blank; }
