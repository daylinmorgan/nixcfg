{
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    git
    git-lfs

    gh
    lazygit
  ];
}
