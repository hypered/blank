let
  pkgs = import <nixpkgs> {};
  repository-version = pkgs.lib.importJSON <repository>;
  repository = pkgs.fetchgit {
    # Ugly string conversion to path.
    url = /. + ("/" + repository-version.url);
    inherit (repository-version) rev sha256;
    leaveDotGit = true; # There seems to be a risk of this feature being
                        # removed because it can be non-deterministic.
  };

  # Default values for the "nubs" attribute (i.e. for when
  # a default.nix file is not present or doesn't contain a
  # "nubs" attribute, or some sub-attribute).
  defaults = rec {

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

    # The default "index" attribute is the main HTML page.
    # Normally it is not overridden.
    index = pkgs.runCommand "index.html" { buildInputs = [ pkgs.git ]; } ''
      mkdir _site
      cat ${top} >> _site/index.html
      echo "<hr />" >> _site/index.html

      echo "show-ref -s fetchgit" > content.tmp1
      echo "<code><pre>" >> content.tmp1
      git --git-dir=${repository}/.git show-ref -s fetchgit >> content.tmp1
      echo "</pre></code>" >> content.tmp1
      echo "<br />" >> content.tmp1
      cat content.tmp1 >> _site/index.html

      echo "ls-tree fetchgit --long" > content.tmp2
      echo "<code><pre>" >> content.tmp2
      git --git-dir=${repository}/.git ls-tree fetchgit --long >> content.tmp2
      echo "</pre></code>" >> content.tmp2
      echo "<br />" >> content.tmp2
      cat content.tmp2 >> _site/index.html

      i=0
      git --git-dir=${repository}/.git ls-tree fetchgit --name-only | \
        while read -r line ; do
          i=$((i + 1))
          echo "<form method=post action=/edit/save onsubmit='this.content.value=document.getElementById(\"c$i\").innerHTML;'>" > content.tmp3
          echo "show fetchgit:$line " >> content.tmp3
          echo "<input type=submit value=Save class=button-as-link />" >> content.tmp3
          echo "<input type=hidden name=repository value=hello />" >> content.tmp3
          echo "<input type=hidden name=filename value=$line />" >> content.tmp3
          echo "<input type=hidden name=content />" >> content.tmp3
          echo "<code><pre id=c$i contenteditable=true spellcheck=false>" >> content.tmp3
          git --git-dir=${repository}/.git show fetchgit:"$line" >> content.tmp3
          echo "</pre></code>" >> content.tmp3
          echo "</form>" >> content.tmp3
          echo "<br />" >> content.tmp3
          cat content.tmp3 >> _site/index.html
        done

      cp _site/index.html $out
    '';

    # Pages is an additional list of files than can be included in the site.
    # By default it is empty.
    pages = pkgs.runCommand "pages" {} ''
      mkdir $out
    '';

    site = pkgs.runCommand "site" {} ''
      mkdir _site
      cat ${templates/begin.html} > _site/index.html
      cat ${index} >> _site/index.html
      cat ${templates/end.html} >> _site/index.html
      cp -r _site $out
      find ${pages} -maxdepth 1 -not -name ${pages} -exec cp -r {} $out/ \;
    '';

  };

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

  # Default nubs attributes, shadowed by the user-defined ones.
  nubs = defaults // (if (default ? "nubs") then default.nubs else {});
in
  default // { inherit nubs; }
