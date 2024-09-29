{ config
, pkgs }:

let
  mkRaw = config.lib.nixvim.mkRaw;
in {
  enable = true;
  viAlias = true;
  vimAlias = true;

  nixpkgs.pkgs = pkgs;

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
      options.desc = "Opens XPLR";
    }
    {
      key = "<leader>f";
      action = "<cmd>Telescope find_files<CR>";
      options.desc = "Opens the Telescope file picker";
    }
    {
      key = "<leader>b";
      action = "<cmd>BufferPick<CR>";
      options.desc = "Opens the tab picker";
    }
    {
      key = "<leader>q";
      action = "<cmd>BufferClose<CR>";
      options.desc = "Closes the current tab";
    }
    {
      key = "<leader>i";
      action = mkRaw ''
        function()
          local file = vim.fn.expand("%:p")
          local first_line = vim.fn.getline(1)

          if string.match(first_line, "^#!/") then
            local escaped_file = vim.fn.shellescape(file)
            vim.cmd("silent! !chmod +x " .. escaped_file)
            vim.cmd("TermExec cmd=" .. escaped_file)
          else
            vim.cmd("echo 'Cannot execute file, missing shebang.'")
          end
        end
      '';
      options.desc = "Executes the current file in the terminal";
    }
    {
      key = "<C-t>";
      action = "<cmd>ToggleTerm<CR>";
      options.desc = "Toggles the terminal";

      mode = [
        "n"
        "t"
        "v"
      ];
    }
  ];

  colorschemes.catppuccin = {
    enable = true;

    settings = {
      flavour = config.catppuccin.flavor;
    };
  };

  extraPlugins = with pkgs; [
    (vimUtils.buildVimPlugin {
      name = "xplr.vim";

      src = fetchFromGitHub {
        owner = "StellarWitch7";
        repo = "xplr.vim";
        rev = "f9bc3800a213d5cb7eaf979e71a96b1f43a81a66";
        hash = "sha256-eLF//fM3+Qxj/fJ1ydrMCrXAvX0kX8Yl7Iz181Fc2Xo=";
      };
    })
  ] ++ (with vimPlugins; [
    #lsp-inlayhints-nvim
    #nvim-lspconfig
  ]);

  plugins = {
    nix.enable = true;
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
    nvim-surround.enable = true;
    treesitter.enable = true;
    
    lsp = {
      enable = true;

      #TODO: questionable second line
      onAttach = ''
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        --require("inlay-hints").on_attach(client, bufnr)
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

    telescope = {
      enable = true;
    };
  };
}
