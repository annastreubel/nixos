{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Network configuration
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.macAddress = "random";
  networking.networkmanager.ethernet.macAddress = "random";
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 51820 ]; # Wireguard
  };

  # Wireguard Settings
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.67.207.72/32" "fc00:bbbb:bbbb:bb01::4:cf47/128" ];
      dns = [ "100.64.0.31" ];
      privateKeyFile = "/home/anna/.wireguard-keys/privatekey";
      
      peers = [
        {
          publicKey = "R5LUBgM/1UjeAR4lt+L/yA30Gee6/VqVZ9eAB3ZTajs=";
          allowedIPs = [ "0.0.0.0/0" "::/0" ];
          endpoint = "193.138.218.80:3017";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  # Power management
  services.thermald.enable = true;
  powerManagement.enable = true;
  services.upower.enable = true;

  # SDD
  services.fstrim.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_DK.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Pantheon Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.budgie.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb = { 
      variant = "";
      layout = "dk";
    };
  };

  # Configure console keymap
  console.keyMap = "dk-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.anna = {
    isNormalUser = true;
    description = "anna";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      ungoogled-chromium
      thunderbird
      git
      signal-desktop
      caprine-bin
      nextcloud-client
      libreoffice-fresh # Spellchecking broken
      onlyoffice-bin
      vlc
      obsidian
      nerdfonts
      R
      rstudio
      mendeley
    ];
  };

    # home-manager setup 
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.anna = {pkgs, ... }: {
    home.stateVersion = "23.05";
    programs.zsh = {
      enable = true;
      autocd = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        icat="kitty +kitten icat";
        clip="kitty +kitten clipboard";
        ls="ls --color=auto";
        ip="ip -c";
      };
      history = {
        size = 10000;
      };
      initExtra = ''
         autoload -U colors && colors
      '';
    };
    programs.kitty = {
      enable = true;
      theme = "Monokai Soda";
      settings = {
        background_opacity = "0.90";
      };
    };
    programs.git = {
      enable = true;
      userName = "Anna Streubel";
      userEmail = "66737680+annastreubel@users.noreply.github.com";
    };
    home.file.".gitconfig" = {
      text = ''
         [pull]
	  rebase = false
     '';
    };
  };
 
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow insecure electron
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.steam.enable = true;

  # Set the system default shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  environment.systemPackages = with pkgs; [
    nftables
    kitty

    zip
    unzip
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

 # Define who can access the Nix package manager
  nix.settings.allowed-users = [ "@wheel" ];

  # Auto optimise storage used by the system
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    persistent = true;
    dates = "monthly";
    options = "-d";
  };

  # Auto upgrade the system
  system.autoUpgrade = {
    enable = true;
    persistent = true;
    dates = "weekly";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
