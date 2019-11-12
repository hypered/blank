let
  pkgs = import <nixpkgs> {};
in
  rec {
    blank.page-1 = pkgs.runCommand "page-1" {} ''
      mkdir $out
      echo This is a user-defined blank.pages page 1. > $out/page-1.html
    '';

    blank.page-2 = pkgs.runCommand "page-1" {} ''
      mkdir $out
      echo This is a user-defined blank.pages page 2. > $out/page-2.html
    '';

    blank.pages = [ blank.page-1 blank.page-2 ];
  }
