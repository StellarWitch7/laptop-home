{ config
, pkgs }:

let
  mkRaw = config.lib.nixvim.mkRaw;
in {
  enable = true;
  viAlias = true;
  vimAlias = true;

  opts = {
    number = true;
    relativenumber = true;
    expandtab = true;
    showmode = false;
    shiftwidth = 4;
    tabstop = 4;
    clipboard = "unnamedplus";
  };

  globals = {
    mapleader = " ";
  };

  keymaps = [
    {
      key = "<leader>g";
      action = "<cmd>XplrPicker %:p:h<CR>";
    }
    {
      key = "<leader>t";
      action = "<cmd>ToggleTerm<CR>";
    }
    {
      key = "<leader>b";
      action = "<cmd>BufferPick<CR>";
    }
    {
      key = "<leader>q";
      action = "<cmd>BufferClose<CR>";
    }
  ];

  colorschemes.catppuccin = {
    enable = true;

    settings = {
      flavour = config.catppuccin.flavor;
    };
  };

  extraPlugins = with pkgs.vimPlugins; [
    lsp-inlayhints-nvim
    nvim-lspconfig
  ];

  plugins = {
    nix.enable = true;
    #oil.enable = true;
    todo-comments.enable = true;
    toggleterm.enable = true;
    refactoring.enable = true;
    scope.enable = true;
    which-key.enable = true;
    hex.enable = true;
    gitsigns.enable = true;
    gitignore.enable = true;
    compiler.enable = true;
    autoclose.enable = true;
    lsp-lines.enable = true;
    specs.enable = true;
    barbar.enable = true;
    web-devicons.enable = true;

    # one of these doesn't work
    #treesitter.enable = true;
    #nvim-surround.enable = true;

    #obsidian.enable = true; # needs more config
    
    lsp = {
      enable = true;

      #TODO: questionable second line
      onAttach = ''
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        require("inlay-hints").on_attach(client, bufnr)
      '';

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

        clangd = {
          enable = true;
        };

        omnisharp = {
          enable = true;
        };

        kotlin-language-server = {
          enable = true;
        };

        jdt-language-server = {
          enable = true;
        };

        #bashls = {
        #  enable = true;
        #};
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

    lightline = {
      enable = true;

      settings = {
        colorscheme = "catppuccin";
      };
    };

    packer = {
      enable = true;

      plugins = [
        {
          name = "sayanarijit/xplr.vim";
          event = "VimEnter";
          config = mkRaw "function() vim.cmd('let g:nnn#replace_netrw = 1') end";
        }
      ];
    };
  };
}
