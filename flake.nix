{
  description = "nix begat oizys";
  outputs = inputs @ {self, ...}:
    (import ./lib {
      inherit inputs;
      inherit self;
    })
    .oizysFlake {};

  inputs = {

    # nixpkgs.url = "github:nixos/nixpkgs/032162631dbfefa15898fc5ddd8daef484fd6d53";
    # nixpkgs.url = "github:nixos/nixpkgs/d5decf6e964b50425195ea8fd831931bb10b064f";
    # nixpkgs.url = "github:nixos/nixpkgs/bfa8b30043892dc2b660d403faa159bab7b65898";
    nixpkgs.url = "github:wegank/nixpkgs/51d879e6533624bd124a60adf8aa3c304a7f9523";

    stable.url = "github:nixos/nixpkgs/nixos-23.11";

    hyprland.url = "github:hyprwm/Hyprland/main";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    hyprland-contrib.url = "github:hyprwm/contrib";
    hyprland-contrib.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-eval-jobs.follows = "nix-eval-jobs";
    };

    nix-eval-jobs.url = "github:nix-community/nix-eval-jobs";
    nix-eval-jobs.inputs.nixpkgs.follows = "nixpkgs";

    pinix.url = "github:remi-dupre/pinix";
    pinix.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-substituters = [
      "https://hyprland.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://daylin.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "daylin.cachix.org-1:fLdSnbhKjtOVea6H9KqXeir+PyhO+sDSPhEW66ClE/k="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };
}
