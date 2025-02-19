{
  lib,
  buildGoModule,
  fetchFromGitHub,
  libpcap,
}:

buildGoModule rec {
  pname = "naabu";
  version = "2.3.2";

  src = fetchFromGitHub {
    owner = "projectdiscovery";
    repo = "naabu";
    tag = "v${version}";
    hash = "sha256-zGZpXnMQ8KvY4oBn0729WmG80AQ4748Gz6UO/+O8i3o=";
  };

  vendorHash = "sha256-Mcp3sfaCNTsBOiDYn3iVolSd9cK2LAGNscoUtYhsRkA=";

  buildInputs = [
    libpcap
  ];

  modRoot = "./v2";

  subPackages = [
    "cmd/naabu/"
  ];

  ldflags = [
    "-w"
    "-s"
  ];

  meta = with lib; {
    description = "Fast SYN/CONNECT port scanner";
    mainProgram = "naabu";
    longDescription = ''
      Naabu is a port scanning tool written in Go that allows you to enumerate
      valid ports for hosts in a fast and reliable manner. It is a really simple
      tool that does fast SYN/CONNECT scans on the host/list of hosts and lists
      all ports that return a reply.
    '';
    homepage = "https://github.com/projectdiscovery/naabu";
    changelog = "https://github.com/projectdiscovery/naabu/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ fab ];
  };
}
