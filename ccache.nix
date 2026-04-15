{
  config,
  lib,
  pkgs,
  ...
}: let
  ccacheOptions = {
    INODECACHE = "true";
    COMPRESS = "true";
    DIR = "${config.programs.ccache.cacheDir}";
    UMASK = "007";
    SLOPPINESS = "random_seed";
    MAXSIZE = "20GB";
    RESHARE = "true";
    REMOTE_STORAGE = "file:///mnt/cache/ccache|update-mtime=true";
    # REMOTE_STORAGE = "file:/mnt/cache/ccache";
  };

  withCcachePrefix = lib.mapAttrs' (name: value: lib.nameValuePair ("CCACHE_" + name) value) ccacheOptions;

  exportVariablesList =
    lib.mapAttrsToList (
      n: v: ''export ${n}="${v}"''
    )
    withCcachePrefix;

  exportVariables = lib.concatStringsSep "\n" exportVariablesList;
in {
  config = {
    nixpkgs.overlays = [
      (self: super: {
        ccacheWrapper = super.ccacheWrapper.override {
          extraConfig = builtins.trace "${exportVariables}" ''
            ${exportVariables}

            if [ ! -d "$CCACHE_DIR" ]; then
              echo "====="
              echo "Directory '$CCACHE_DIR' does not exist"
              echo "Please create it with:"
              echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
              echo "  sudo chown root:nixbld '$CCACHE_DIR'"
              echo "====="
              exit 1
            fi
            if [ ! -w "$CCACHE_DIR" ]; then
              echo "====="
              echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
              echo "Please verify its access permissions"
              echo "====="
              exit 1
            fi
          '';
        };
      })
    ];

    environment = {
      systemPackages = [pkgs.ccache];
      variables = withCcachePrefix;
    };

    programs.ccache.enable = true;
  };
}
