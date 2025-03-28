{
  pkgs,
  lib,
  config,
  enabled,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    literalExpression
    types
    optionals
    ;
  cfg = config.oizys.nix-ld;

  # https://github.com/NixOS/nixpkgs/blob/a4f437f0f5db62e6bcd7979c10eab177dd0fa188/nixos/modules/programs/nix-ld.nix#L44-L59
  defaultLibraries = with pkgs; [
    zlib
    zstd
    stdenv.cc.cc
    curl
    openssl
    attr
    libssh
    bzip2
    libxml2
    acl
    libsodium
    util-linux
    xz
    systemd
  ];

  # https://github.com/Mic92/dotfiles/blob/340152bdf4bd193269474426ca5d90c479aae0b7/nixos/modules/nix-ld.nix#L7-L58
  overkillLibraries = with pkgs; [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    curl
    dbus
    expat
    fontconfig
    freetype
    fuse3
    gdk-pixbuf
    glib
    gtk3
    icu
    libGL
    libappindicator-gtk3
    libdrm
    libglvnd
    libnotify
    libpulseaudio
    libunwind
    libusb1
    libuuid
    libxkbcommon
    mesa
    nspr
    nss
    openssl
    pango
    pipewire
    stdenv.cc.cc
    systemd
    vulkan-loader
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libxcb
    xorg.libxkbfile
    xorg.libxshmfence
    zlib
    libgbm
  ];

in
{
  options.oizys.nix-ld = {
    enable = mkEnableOption "enable nix-ld support";
    extra-libraries = mkOption {
      type = types.listOf types.package;
      description = "Libraries that automatically become available to all programs.";
      default = [ ];
      defaultText = literalExpression "baseLibraries derived from systemd and nix dependencies.";
    };
    overkill.enable = mkEnableOption "enable overkill list of libraries";

  };

  config =
    let
      libs = defaultLibraries ++ cfg.extra-libraries ++ (optionals cfg.overkill.enable overkillLibraries);
    in
    mkIf cfg.enable {
      programs.nix-ld = enabled // {
        package = pkgs.nix-ld-rs;
        libraries = libs;
      };
    };
}
