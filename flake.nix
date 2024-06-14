{
  description = "Notes on the mode splitting in coupled fibre-loops";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib; eachSystem allSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-medium latexmk koma-script babel-english
            physics mathtools amsmath fontspec booktabs siunitx caption biblatex float
            pgfplots microtype fancyvrb csquotes setspace newunicodechar hyperref
            cleveref multirow bbold unicode-math biblatex-phys xpatch beamerposter
            type1cm changepage lualatex-math footmisc wrapfig2 curve2e pict2e wrapfig
            appendixnumberbeamer sidecap appendix orcidlink ncctools bigfoot crop xcolor
            acro translations tikzscale xstring pagesel biblatex-ieee preview zref zref-clever
            aligned-overset
            tex-gyre-math  tex-gyre sttools euler-math newcomputermodern fontsetup imakeidx glossaries nomencl;
        };
      in
      rec {
        packages = {
          document = pkgs.stdenvNoCC.mkDerivation rec {
            name = "notes";
            src = self;
            buildInputs = [ pkgs.coreutils tex pkgs.biber ];
            phases = [ "unpackPhase" "buildPhase" "installPhase" ];
            buildPhase = ''
              export PATH="${pkgs.lib.makeBinPath buildInputs}";
              export SOURCE_DATE_EPOCH="${toString self.sourceInfo.lastModified}"

              cd papers/Report/
              mkdir -p .cache/texmf-var
              mkdir -p output/src

              env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
                latexmk index.tex
            '';
            installPhase = ''
              mkdir -p $out
              cp output/index.pdf $out/
            '';
          };
        };
        defaultPackage = packages.document;
        devShell = pkgs.mkShellNoCC {
          buildInputs = packages.document.buildInputs ++ [pkgs.ghostscript];
          shellHook = ''
            export TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var

            export SOURCE_DATE_EPOCH="${toString packages.document.src.lastModified}"
          '';
        };
      });
}
