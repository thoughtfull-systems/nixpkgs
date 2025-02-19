{
  lib,
  stdenv,
  fetchFromGitHub,

  SDL2,
  cmake,
  curl,
  discord-rpc,
  duktape,
  expat,
  flac,
  fontconfig,
  freetype,
  gbenchmark,
  icu,
  jansson,
  libGLU,
  libiconv,
  libogg,
  libpng,
  libpthreadstubs,
  libvorbis,
  libzip,
  nlohmann_json,
  openssl,
  pkg-config,
  speexdsp,
  zlib,
}:

let
  openrct2-version = "0.4.15";

  # Those versions MUST match the pinned versions within the CMakeLists.txt
  # file. The REPLAYS repository from the CMakeLists.txt is not necessary.
  objects-version = "1.4.8";
  openmsx-version = "1.6";
  opensfx-version = "1.0.5";
  title-sequences-version = "0.4.14";

  openrct2-src = fetchFromGitHub {
    owner = "OpenRCT2";
    repo = "OpenRCT2";
    rev = "v${openrct2-version}";
    hash = "sha256-VumjJGAur+2A7n0pFcNM7brYaoeaVCPBtRGFIZmq5QY=";
  };

  objects-src = fetchFromGitHub {
    owner = "OpenRCT2";
    repo = "objects";
    rev = "v${objects-version}";
    hash = "sha256-A6iFaWda5qiFirGqOP6H9w0PP5Me8BRr2HXKZPHJImE=";
  };

  openmsx-src = fetchFromGitHub {
    owner = "OpenRCT2";
    repo = "OpenMusic";
    rev = "v${openmsx-version}";
    hash = "sha256-KjWJSB2tdE0ExswVlz0dLXNPhLJ1kI6VZb3vqXQfx8w=";
  };

  opensfx-src = fetchFromGitHub {
    owner = "OpenRCT2";
    repo = "OpenSoundEffects";
    rev = "v${opensfx-version}";
    hash = "sha256-ucADnMLGm36eAo+NiioxEzeMqtu7YbGF9wsydK1mmoE=";
  };

  title-sequences-src = fetchFromGitHub {
    owner = "OpenRCT2";
    repo = "title-sequences";
    rev = "v${title-sequences-version}";
    hash = "sha256-ier7sBYJjBIvKVxfaCelJPZ+oF9NEshvR2k/X9JpP+0=";
  };
in
stdenv.mkDerivation {
  pname = "openrct2";
  version = openrct2-version;

  src = openrct2-src;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    SDL2
    curl
    discord-rpc
    duktape
    expat
    flac
    fontconfig
    freetype
    gbenchmark
    icu
    jansson
    libGLU
    libiconv
    libogg
    libpng
    libpthreadstubs
    libvorbis
    libzip
    nlohmann_json
    openssl
    speexdsp
    zlib
  ];

  cmakeFlags = [
    "-DDOWNLOAD_OBJECTS=OFF"
    "-DDOWNLOAD_OPENMSX=OFF"
    "-DDOWNLOAD_OPENSFX=OFF"
    "-DDOWNLOAD_TITLE_SEQUENCES=OFF"
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    # Needed with GCC 12
    "-Wno-error=maybe-uninitialized"
  ];

  postUnpack = ''
    mkdir -p $sourceRoot/data/assetpack

    cp -r ${objects-src}         $sourceRoot/data/object
    cp -r ${openmsx-src}         $sourceRoot/data/assetpack/openrct2.music.alternative.parkap
    cp -r ${opensfx-src}         $sourceRoot/data/assetpack/openrct2.sound.parkap
    cp -r ${title-sequences-src} $sourceRoot/data/sequence
  '';

  preConfigure =
    # Verify that the correct version of each third party repository is used.
    (
      let
        versionCheck = cmakeKey: version: ''
          grep -q '^set(${cmakeKey}_VERSION "${version}")$' CMakeLists.txt \
            || (echo "${cmakeKey} differs from expected version!"; exit 1)
        '';
      in
      (versionCheck "OBJECTS" objects-version)
      + (versionCheck "OPENMSX" openmsx-version)
      + (versionCheck "OPENSFX" opensfx-version)
      + (versionCheck "TITLE_SEQUENCE" title-sequences-version)
    );

  preFixup = "ln -s $out/share/openrct2 $out/bin/data";

  meta = with lib; {
    description = "Open source re-implementation of RollerCoaster Tycoon 2 (original game required)";
    homepage = "https://openrct2.io/";
    downloadPage = "https://github.com/OpenRCT2/OpenRCT2/releases";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ oxzi ];
  };
}
