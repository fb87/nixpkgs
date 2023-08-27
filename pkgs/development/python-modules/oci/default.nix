{ lib
, buildPythonPackage
, certifi
, circuitbreaker
, cryptography
, fetchFromGitHub
, pyopenssl
, python-dateutil
, pythonOlder
, pythonRelaxDepsHook
, pytz
}:

buildPythonPackage rec {
  pname = "oci";
  version = "2.110.2";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "oracle";
    repo = "oci-python-sdk";
    rev = "refs/tags/v${version}";
    hash = "sha256-4+qP/eCd3xy0Q3Nrwbj2VpyNWqiKL82nrX7Od0yHToo=";
  };

  pythonRelaxDeps = [
    "cryptography"
    "pyOpenSSL"
  ];

  nativeBuildInputs = [
    pythonRelaxDepsHook
  ];

  propagatedBuildInputs = [
    certifi
    circuitbreaker
    cryptography
    pyopenssl
    python-dateutil
    pytz
  ];

  # Tests fail: https://github.com/oracle/oci-python-sdk/issues/164
  doCheck = false;

  pythonImportsCheck = [
    "oci"
  ];

  meta = with lib; {
    description = "Oracle Cloud Infrastructure Python SDK";
    homepage = "https://github.com/oracle/oci-python-sdk";
    changelog = "https://github.com/oracle/oci-python-sdk/blob/v${version}/CHANGELOG.rst";
    license = with licenses; [ asl20 /* or */ upl ];
    maintainers = with maintainers; [ ilian ];
  };
}
