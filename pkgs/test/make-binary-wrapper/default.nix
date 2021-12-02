{ lib, stdenv, runCommand, makeBinaryWrapper }:

let
  makeGoldenTest = { name, filename }: stdenv.mkDerivation {
    name = name;
    dontUnpack = true;
    strictDeps = true;
    nativeBuildInputs = [ makeBinaryWrapper ];
    phases = [ "installPhase" ];
    installPhase = ''
      source ${./golden-test-utils.sh}
      mkdir -p $out/bin
      command=$(getInputCommand "${filename}")
      eval "$command" > "$out/bin/result"
    '';
    passthru = {
      assertion = ''
        source ${./golden-test-utils.sh}
        contents=$(getOutputText "${filename}")
        echo "$contents" | diff $out/bin/result -
      '';
    };
  };
  tests = {
    basic = makeGoldenTest { name = "basic"; filename = ./basic.c; };
    argv0 = makeGoldenTest { name = "argv0"; filename = ./argv0.c; };
    inherit_argv0 = makeGoldenTest { name = "inherit-argv0"; filename = ./inherit-argv0.c; };
    env = makeGoldenTest { name = "env"; filename = ./env.c; };
    invalid_env = makeGoldenTest { name = "invalid-env"; filename = ./invalid-env.c; };
    prefix = makeGoldenTest { name = "prefix"; filename = ./prefix.c; };
    suffix = makeGoldenTest { name = "suffix"; filename = ./suffix.c; };
    add_flags = makeGoldenTest { name = "add-flags"; filename = ./add-flags.c; };
    chdir = makeGoldenTest { name = "chdir"; filename = ./chdir.c; };
    combination = makeGoldenTest { name = "combination"; filename = ./combination.c; };
  };
in runCommand "make-binary-wrapper-test" {
  passthru = tests;
  meta.platforms = lib.platforms.all;
} ''
  validate() {
    local name=$1
    local testout=$2
    local assertion=$3

    echo -n "... $name: " >&2

    local rc=0
    (out=$testout eval "$assertion") || rc=1

    if [ "$rc" -eq 0 ]; then
      echo "yes" >&2
    else
      echo "no" >&2
    fi

    return "$rc"
  }

  echo "checking whether makeCWrapper works properly... ">&2

  fail=
  ${lib.concatStringsSep "\n" (lib.mapAttrsToList (_: test: ''
    validate "${test.name}" "${test}" ${lib.escapeShellArg test.assertion} || fail=1
  '') tests)}

  if [ "$fail" ]; then
    echo "failed"
    exit 1
  else
    echo "succeeded"
    touch $out
  fi
''
