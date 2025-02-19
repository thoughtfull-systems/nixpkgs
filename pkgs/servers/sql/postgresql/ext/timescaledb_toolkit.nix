{
  lib,
  fetchFromGitHub,
  buildPgrxExtension,
  postgresql,
  nixosTests,
  cargo-pgrx_0_10_2,
  nix-update-script,
}:

(buildPgrxExtension.override { cargo-pgrx = cargo-pgrx_0_10_2; }) rec {
  inherit postgresql;

  pname = "timescaledb_toolkit";
  version = "1.18.0";

  src = fetchFromGitHub {
    owner = "timescale";
    repo = "timescaledb-toolkit";
    rev = version;
    hash = "sha256-Lm/LFBkG91GeWlJL9RBqP8W0tlhBEeGQ6kXUzzv4xRE=";
  };

  cargoHash = "sha256-LME8oftHmmiN8GU3eTBTSB6m0CE+KtDFRssL1g2Cjm8=";
  buildAndTestSubdir = "extension";

  passthru = {
    updateScript = nix-update-script { };
    tests = nixosTests.postgresql.timescaledb.passthru.override postgresql;
  };

  # tests take really long
  doCheck = false;

  meta = with lib; {
    description = "Provide additional tools to ease all things analytic when using TimescaleDB";
    homepage = "https://github.com/timescale/timescaledb-toolkit";
    maintainers = with maintainers; [ typetetris ];
    platforms = postgresql.meta.platforms;
    license = licenses.tsl;
    # PostgreSQL 17 support issue upstream: https://github.com/timescale/timescaledb-toolkit/issues/813
    # Check after next package update.
    broken = versionAtLeast postgresql.version "17" && version == "1.18.0";
  };
}
