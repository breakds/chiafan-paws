{ pkgs, lib }:

pkgs.python3Packages.buildPythonApplication rec {
  pname = "chiafan";
  version = "0.1.0";

  src = pkgs.fetchgit {
    url = "https://github.com/breakds/chiafan.git";
    rev = "8880c175f227579068c26d9d51649a388eff9481";
    sha256 = "sha256-VmWByNOyWhgLXxfHHFREg2Nu1Xx+pkuPyu5PUeOav1g=";
  };

  propagatedBuildInputs = with pkgs.python3Packages; [
    click flask
  ];
}
