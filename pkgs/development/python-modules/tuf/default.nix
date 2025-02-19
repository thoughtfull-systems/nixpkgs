{
  lib,
  buildPythonPackage,
  ed25519,
  fetchFromGitHub,
  hatchling,
  pytestCheckHook,
  pythonOlder,
  requests,
  securesystemslib,
}:

buildPythonPackage rec {
  pname = "tuf";
  version = "3.1.1";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "theupdateframework";
    repo = "python-tuf";
    tag = "v${version}";
    hash = "sha256-HiF/b6aOhDhhQqYx/bjMXHABxmAJY4vkLlTheiL8zEo=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "hatchling==" "hatchling>="
  '';

  nativeBuildInputs = [ hatchling ];

  propagatedBuildInputs =
    [
      requests
      securesystemslib
    ]
    ++ securesystemslib.optional-dependencies.pynacl
    ++ securesystemslib.optional-dependencies.crypto;

  nativeCheckInputs = [
    ed25519
    pytestCheckHook
  ];

  pythonImportsCheck = [ "tuf" ];

  preCheck = ''
    cd tests
  '';

  meta = with lib; {
    description = "Python reference implementation of The Update Framework (TUF)";
    homepage = "https://github.com/theupdateframework/python-tuf";
    changelog = "https://github.com/theupdateframework/python-tuf/blob/v${version}/docs/CHANGELOG.md";
    license = with licenses; [
      asl20
      mit
    ];
    maintainers = with maintainers; [ fab ];
  };
}
