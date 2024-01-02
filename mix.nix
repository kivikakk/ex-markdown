{
  lib,
  beamPackages,
  overrides ? (x: y: {}),
}: let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages = with beamPackages;
  with self; {
    earmark = buildMix rec {
      name = "earmark";
      version = "1.2.5";

      src = fetchHex {
        pkg = "earmark";
        version = "${version}";
        sha256 = "c57508ddad47dfb8038ca6de1e616e66e9b87313220ac5d9817bc4a4dc2257b9";
      };

      beamDeps = [];
    };

    ex_doc = buildMix rec {
      name = "ex_doc";
      version = "0.18.3";

      src = fetchHex {
        pkg = "ex_doc";
        version = "${version}";
        sha256 = "33d7b70d87d45ed899180fb0413fb77c7c48843188516e15747e00fdecf572b6";
      };

      beamDeps = [earmark];
    };

    html_entities = buildMix rec {
      name = "html_entities";
      version = "0.5.2";

      src = fetchHex {
        pkg = "html_entities";
        version = "${version}";
        sha256 = "c53ba390403485615623b9531e97696f076ed415e8d8058b1dbaa28181f4fdcc";
      };

      beamDeps = [];
    };

    jason = buildMix rec {
      name = "jason";
      version = "1.4.1";

      src = fetchHex {
        pkg = "jason";
        version = "${version}";
        sha256 = "fbb01ecdfd565b56261302f7e1fcc27c4fb8f32d56eab74db621fc154604a7a1";
      };

      beamDeps = [];
    };

    rustler = buildMix rec {
      name = "rustler";
      version = "0.30.0";

      src = fetchHex {
        pkg = "rustler";
        version = "${version}";
        sha256 = "9ef1abb6a7dda35c47cfc649e6a5a61663af6cf842a55814a554a84607dee389";
      };

      beamDeps = [jason toml];
    };

    toml = buildMix rec {
      name = "toml";
      version = "0.7.0";

      src = fetchHex {
        pkg = "toml";
        version = "${version}";
        sha256 = "0690246a2478c1defd100b0c9b89b4ea280a22be9a7b313a8a058a2408a2fa70";
      };

      beamDeps = [];
    };
  };
in
  self
