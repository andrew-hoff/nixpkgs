{ lib
, buildGoPackage
, fetchFromGitHub
, openssl
, pkg-config
, libpcap
}:

let
  tools = [
    "bsondump"
    "mongoimport"
    "mongoexport"
    "mongodump"
    "mongorestore"
    "mongostat"
    "mongofiles"
    "mongotop"
  ];
  version = "100.5.3";

in buildGoPackage {
  pname = "mongo-tools";
  inherit version;

  goPackagePath = "github.com/mongodb/mongo-tools";
  subPackages = tools;

  src = fetchFromGitHub {
    rev = version;
    owner = "mongodb";
    repo = "mongo-tools";
    sha256 = "sha256-8RkpBCFVxKVsu4h2z+rhlwvYfbSDHZUg8erO4+2GRbw=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl libpcap ];

  # Mongodb incorrectly names all of their binaries main
  # Let's work around this with our own installer
  buildPhase = ''
    # move vendored codes so nixpkgs go builder could find it
    runHook preBuild

    ${lib.concatMapStrings (t: ''
      go build -o "$out/bin/${t}" -tags ssl -ldflags "-s -w" $goPackagePath/${t}/main
    '') tools}

    runHook postBuild
  '';

  meta = {
    homepage = "https://github.com/mongodb/mongo-tools";
    description = "Tools for the MongoDB";
    maintainers = with lib.maintainers; [ bryanasdev000 ];
    license = lib.licenses.asl20;
  };
}
