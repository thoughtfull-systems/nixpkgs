{
  lib,
  stdenv,
  fetchFromGitHub,
  wrapGAppsHook3,
  cmake,
  gettext,
  maxima,
  wxGTK,
  adwaita-icon-theme,
  glib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wxmaxima";
  version = "24.08.0";

  src = fetchFromGitHub {
    owner = "wxMaxima-developers";
    repo = "wxmaxima";
    rev = "Version-${finalAttrs.version}";
    hash = "sha256-W9sZlCPi+pz37OQoICnRGQR2hoe/UciMN6NIzDgHNPQ=";
  };

  buildInputs = [
    wxGTK
    maxima
    # So it won't embed svg files into headers.
    adwaita-icon-theme
    # So it won't crash under Sway.
    glib
  ];

  nativeBuildInputs = [
    wrapGAppsHook3
    cmake
    gettext
  ];

  cmakeFlags = [
    "-DwxWidgets_LIBRARIES=${wxGTK}/lib"
  ];

  preConfigure = ''
    gappsWrapperArgs+=(--prefix PATH ":" ${maxima}/bin)
  '';

  meta = with lib; {
    description = "Cross platform GUI for the computer algebra system Maxima";
    mainProgram = "wxmaxima";
    license = licenses.gpl2;
    homepage = "https://wxmaxima-developers.github.io/wxmaxima/";
    maintainers = with maintainers; [ doronbehar ];
    platforms = platforms.linux;
  };
})
