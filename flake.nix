{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";

  outputs = { self, nixpkgs }: {

    overlay = final: prev: {
      dictdDBs = prev.dictdDBs // {
        eijiro = with final; stdenvNoCC.mkDerivation {
          name = "dictd-db-eijiro";
          src = ./EIJIRO-1448.ZIP;

          locale = "en_UK";
          dbName = "eijiro";

          buildInputs = [ nkf dict unzip ];

          unpackPhase = ''
            unzip $src
          '';

          patchPhase = ''
            nkf -wd EIJIRO-1448.TXT > eijiro.txt.utf8
            sed -i -e 's/^\xe2\x96\xa0/:/' -e 's/ : /:/' eijiro.txt.utf8
          '';

          buildPhase = ''
            dictfmt -j --utf8 -s "eijiro" eijiro < eijiro.txt.utf8
          '';

          installPhase = ''
            mkdir -p $out/share/dictd
            cp $(ls eijiro.{dict*,index}) $out/share/dictd
            echo "en_UK" > $out/share/dictd/locale
          '';

          meta = {
            description = "dictd-db dictionary for dictd";
            platforms = stdenv.lib.platforms.linux;
          };
        };
      };
    };

    defaultPackage.x86_64-linux =
      (
        import nixpkgs {
          system = "x86_64-linux";
          overlays = [ self.outputs.overlay ];
        }
      ).dictdDBs.eijiro;
  };
}
