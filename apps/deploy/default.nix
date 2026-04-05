{
  nixos-rebuild-ng,
  self,
  writeShellApplication,
}:

writeShellApplication {
  name = "nixos-deploy";
  runtimeInputs = [ nixos-rebuild-ng ];

  text = ''
    nixos-rebuild switch \
      --flake "${self}#rpi5" \
      --no-reexec \
      --show-trace \
      --sudo \
      --target-host ssh://qeden@rpi5
  '';
}
