let
  sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKP9m53womx+hnQFRljUzv/PrCuFEYKgmPrmdzYSMQcX";
in

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  users.users.qeden.openssh.authorizedKeys.keys = [ sshPubKey ];
  users.users.root.openssh.authorizedKeys.keys = [ sshPubKey ];
}
