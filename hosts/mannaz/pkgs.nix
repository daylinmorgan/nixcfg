{ pkgs, ... }:
{
  environment.systemPackages = (
    with pkgs;
    [
      nvitop
      sops
    ]
  );
}
