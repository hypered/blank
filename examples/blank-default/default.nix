let
  pkgs = import <nixpkgs> {};
in
  {
    blank.top = pkgs.runCommand "top.html" {} ''
      echo This is a user-defined blank.top attribute. > $out
    '';
  }
