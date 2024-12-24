{
  inputs,
  pkgs,
  flake,
  enabled,
  ...
}:
let
  inherit (inputs) NixVirt;
  defaultNetwork = {
    definition = NixVirt.lib.network.writeXML (
      NixVirt.lib.network.templates.bridge {
        uuid = "e7955c23-8750-4405-ab2c-37aeee441f67";
        subnet_byte = 24;
      }
    );
  };
  win-desktop = pkgs.stdenvNoCC.mkDerivation rec {
    name = "win11-vm";
    unpackPhase = "true";
    version = "unstable";
    windows10Logo = pkgs.fetchurl {
      url = "https://upload.wikimedia.org/wikipedia/commons/c/c7/Windows_logo_-_2012.png";
      hash = "sha256-uVNgGUo0NZN+mUmvMzyk0HKnhx64uqT4YWGSdeBz3T4=";
    };

    desktopItem = pkgs.makeDesktopItem {
      name = "win11-vm";
      # exec = "VBoxManage startvm win10";
      exec = "${pkgs.libvirt}/bin/virsh start win11 && ${pkgs.virt-viewer}/bin/virt-viewer --wait -c qemu:///system win11 && ${pkgs.libvirt}/bin/virsh shutdown win11";
      icon = "${windows10Logo}";
      desktopName = "Windows 11 VM";
    };
    installPhase = ''
      install -Dm0644 {${desktopItem},$out}/share/applications/win11vm.desktop
    '';
  };

in
{
  imports = [
    (flake.module "NixVirt")
  ];

  programs.virt-manager = enabled;

  virtualisation = {
    libvirt = enabled // {
      swtpm = enabled;
      connections."qemu:///system" = {
        networks = [ defaultNetwork ];
        domains = [
          { definition = ./win11.xml; }
        ];
      };
    };
    libvirtd.qemu = {
      # ovmf.packages = [ pkgs.OVMFFull.fd ];
      vhostUserPackages = [ pkgs.virtiofsd ];
    };

    # Enable USB redirection (optional)
    spiceUSBRedirection = enabled;
  };

  users.users.daylin = {
    extraGroups = [ "libvirtd" ];
  };

  environment.systemPackages = [ win-desktop ];
}
