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
      key = "<leader>d";
      action = mkRaw ''
        function()
          vim.diagnostic.open_float(0, {scope="line"})
        end
      '';
      options.desc = "Displays off-screen text for the current line";
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

  autoCmd = [
    {
      event = [ "BufWritePost" ];
      pattern = [ "*.java" ];
      callback = mkRaw ''
        function()
          pcall(vim.lsp.codelens.refresh)
        end
      '';
    }
    {
      event = [ "BufLeave" ];
      pattern = [ "term://*" ];
      command = "stopinsert";
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
  ];

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
    lsp-signature.enable = true;
    specs.enable = true;
    barbar.enable = true;
    web-devicons.enable = true;
    nvim-surround.enable = true;
    treesitter.enable = true;
    dap.enable = true;
    image.enable = true;
    
    lsp = {
      enable = true;
      inlayHints = true;

      keymaps = {
        lspBuf = {
          gd = "definition";
          gr = "references";
          gi = "implementation";
          rn = "rename";
          ca = "code_action";
          "<C-k>" = "signature_help";
        };
      };

      onAttach = ''
        pcall(vim.lsp.codelens.refresh)
      '';

      servers = {
        pylyzer = {
          enable = true;
        };

        metals = {
          enable = true;
        };

        nixd = {
          enable = true;

          settings = {
            diagnostic.suppress = [
              "sema-escaping-with"
            ];
          };
        };

        rust_analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;

          settings = {
            checkOnSave = false;

            completion = {
              autoimport = {
                enable = true;
              };
            };

            lens = {
              enable = true;

              implementations = {
                enable = true;
              };

              references = {
                adt.enable = true;
                enumVariant.enable = true;
                method.enable = true;
                trait.enable = true;
              };
            };

            inlayHints = {
              renderColons = true;
              maxLength = 25;

              bindingModeHints = {
                enable = false;
              };

              chainingHints = {
                enable = true;
              };

              closingBraceHints = {
                enable = true;
                minLines = 25;
              };

              closureReturnTypeHints = {
                enable = "never";
              };

              lifetimeElisionHints = {
                enable = "never";
                useParameterNames = false;
              };

              parameterHints = {
                enable = true;
              };

              reborrowHints = {
                enable = "never";
              };
              
              typeHints = {
                enable = true;
                hideClosureInitialization = false;
                hideNamedConstructor = false;
              };
            };
          };
        };

        hls = {
          enable = true;
          installGhc = true;
        };

        clangd = {
          enable = true;

          settings = {
            InlayHints = {
              Designators = true;
              Enabled = true;
              ParameterNames = true;
              DeducedTypes = true;
            };

            fallbackFlags = [ "-std=c++20" ];
          };
        };

        omnisharp = {
          enable = true;
        };

        kotlin_language_server = {
          enable = true;

          settings = {
            hints = {
              typeHints = true;
              parameterHints = true;
              chaineHints = true;
            };
          };
        };

        jdtls = {
          enable = true;

          settings = {
            java = {
              eclipse = {
                downloadSources = true;
              };

              gradle = {
                enabled = true;
              };

              maven = {
                downloadSources = true;
              };
              
              implementationsCodeLens = {
                enabled = true;
              };

              referencesCodeLens = {
                enabled = true;
              };

              references = {
                includeDecompiledSources = true;
              };
              
              inlayHints = {
                parameterNames = {
                  enabled = "all";
                };
              };

              codeGeneration = {
                toString = {
                  template = "\${object.className}{\${member.name()}=\${member.value}, \${otherMembers}}";
                };

                hashCodeEquals = {
                  useJava7Objects = true;
                };

                useBlocks = true;
              };
            };
          };

          extraOptions = {
            signatureHelp = {
              enabled = true;
            };

            contentProvider = {
              preferred = "fernflower";
            };

            sources = {
              organizeImports = {
                starThreshold = 9999;
                staticStarThreshold = 9999;
              };
            };

            
            codeGeneration = {
              toString = {
                template = "\${object.className}{\${member.name()}=\${member.value}, \${otherMembers}}";
              };

              useBlocks = true;
            };

            flags = {
              allow_incremental_sync = true;
            };

            init_options = {
              bundles = mkRaw "{ vim.fn.glob('${./.}/com.microsoft.java.debug.plugin-*.jar'), }";
            };
          };
        };

        bashls = {
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
