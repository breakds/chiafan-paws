{ pkgs, lib }:

pkgs.python3Packages.buildPythonApplication rec {
  pname = "chiafan";
  version = "0.1.0";

  src = pkgs.fetchgit {
    url = "https://github.com/breakds/chiafan.git";
    rev = "8dadb8d0ce56469c722ea91871d06a03dec52a1d";
    sha256 = "sha256-1NBJyoUXM+gnp9jkPrI92sj3CuxZgErK1tFiLC+4wnU=";
  };

  propagatedBuildInputs = with pkgs.python3Packages; [
    click flask
  ];
}
