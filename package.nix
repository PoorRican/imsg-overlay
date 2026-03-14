{ lib, stdenv, fetchFromGitHub, fetchgit }:

let
  pname = "imsg";
  version = "0.5.0";

  packageResolved = ./Package.resolved;

  commanderSrc = fetchgit {
    url = "https://github.com/steipete/Commander.git";
    rev = "9e349575c8e3c6745e81fe19e5bb5efa01b078ce";
    hash = "sha256-ojQha470/9t6t7EzzPWlJQaLSmcn4xNPZtfPnFbcGOA=";
    leaveDotGit = true;
  };

  phoneNumberKitSrc = fetchgit {
    url = "https://github.com/marmelroy/PhoneNumberKit.git";
    rev = "ad20aba8db84a6ba373abfcffe38b1c8e6f8258b";
    hash = "sha256-HTvyD8+0n30SacX80hrbXRNNwBn2IhbN1YJfpCyi4z8=";
    leaveDotGit = true;
  };

  sqliteSwiftSrc = fetchgit {
    url = "https://github.com/stephencelis/SQLite.swift.git";
    rev = "964c300fb0736699ce945c9edb56ecd62eba27a3";
    hash = "sha256-cfaqWqYaWSLs91bo3u0lAAfoNT+QEQu1qLN/BBGDzQo=";
    leaveDotGit = true;
  };
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "steipete";
    repo = "imsg";
    rev = "v${version}";
    hash = "sha256-eBRryTcT5mn6WKOlkdIAeFg/La7Kr7H70gvGBrUw5N0=";
  };

  strictDeps = true;

  configurePhase = ''
    runHook preConfigure

    mkdir -p .build/checkouts
    cp ${packageResolved} Package.resolved

    ln -s ${commanderSrc} .build/checkouts/commander
    ln -s ${phoneNumberKitSrc} .build/checkouts/phonenumberkit
    ln -s ${sqliteSwiftSrc} .build/checkouts/sqlite.swift

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    export HOME="$TMPDIR/home"
    export CFFIXED_USER_HOME="$HOME"
    export XDG_CACHE_HOME="$HOME/.cache"
    export XDG_CONFIG_HOME="$HOME/.config"
    mkdir -p "$HOME" "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME"
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    export SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.2.sdk
    export PATH="$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin:$DEVELOPER_DIR/usr/bin:$PATH"
    swift build -c release --disable-sandbox --disable-automatic-resolution
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 .build/release/imsg -t $out/bin
    runHook postInstall
  '';

  meta = with lib; {
    description = "CLI to send, read, and stream iMessage/SMS via macOS Messages.app";
    homepage = "https://github.com/steipete/imsg";
    changelog = "https://github.com/steipete/imsg/releases/tag/v${version}";
    license = licenses.mit;
    mainProgram = "imsg";
    platforms = platforms.darwin;
  };
}
