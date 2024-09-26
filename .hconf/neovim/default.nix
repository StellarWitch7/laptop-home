{ config
, pkgs
, dir }:

let
  mkRaw = config.lib.nixvim.mkRaw;
in {
  enable = true;

  opts = {
    number = true;
    relativenumber = true;
    expandtab = true;
    shiftwidth = 4;
    tabstop = 4;
  };

  globals = {
    mapleader = " ";
  };

  keymaps = [
    {
      key = "<leader>g";
      action = "<cmd>Oil<CR>";
    }
    {
      key = "<leader>b";
      action = "<cmd>ToggleTerm<CR>";
    }
  ];

  extraPlugins = with pkgs.vimPlugins; [
    # nothing to put here yet
  ];

  plugins = {
    lazy.enable = true;
    nix.enable = true;
    oil.enable = true;
    todo-comments.enable = true;
    toggleterm.enable = true;
    refactoring.enable = true;
    scope.enable = true;
    which-key.enable = true;
    hex.enable = true;
    gitignore.enable = true;
    compiler.enable = true;
    autoclose.enable = true;
    lsp-lines.enable = true;

    # one of these doesn't work
    #treesitter.enable = true;
    #nvim-surround.enable = true;

    #obsidian.enable = true; # needs more config
    
    lsp = {
      enable = true;

      servers = {
        nixd = {
          enable = true;
        };

        rust-analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;

          settings = {
            checkOnSave = false;
          };
        };

        hls = {
          enable = true;
        };

        #bashls = {
        #  enable = true;
        #};

        clangd = {
          enable = true;
        };

        omnisharp = {
          enable = true;
        };

        kotlin-language-server = {
          enable = true;
        };
      };
    };

    coq-nvim = {
      enable = true;
      installArtifacts = true;

      settings = {
        xdg = true;
        auto_start = "shut-up";
      };
    };

    nvim-jdtls = {
      enable = true;
      configuration = "${dir}/.config/jdtls/config";
      data = mkRaw "os.getenv \"HOME\" .. \"/.local/share/jdtls/workspace/\" .. vim.fn.fnamemodify(vim.fn.getcwd(), \":p:h:t\")";
      rootDir = mkRaw "require('jdtls.setup').find_root({'.git', 'build.gradle', 'gradlew'})";
    };

    packer = {
      enable = true;

      plugins = [
        {
          name = "fhill2/xplr.nvim";
          run = mkRaw "function() require('xplr').install({hide=true}) end";
          requires = [
            "nvim-lua/plenary.nvim"
            "MunifTanjim/nui.nvim"
          ];
        }
      ];
    };
  };
}
