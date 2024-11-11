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
      key = "<leader>t";
      action = "<cmd>Telescope grep_string<CR>";
      options.desc = "Opens the Telescope text search";
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
      key = "<leader>.";
      action = "<cmd>lua require'dap'.toggle_breakpoint()<CR>";
      options.desc = "Toggles a breakpoint on the current line";
    }
    {
      key = "<leader>,";
      action = "<cmd>lua require'dap'.step_over()<CR>";
      options.desc = "Step over line";
    }
    {
      key = "<leader>l";
      action = "<cmd>lua require'dap'.step_into()<CR>";
      options.desc = "Step into line";
    }
    {
      key = "<C-s>";
      action = "<cmd>lua require'dap'.continue()<CR>";
      options.desc = "Debugger";

      mode = [
        "n"
        "v"
      ];
    }
    {
      key = "<C-d>";
      action = "<cmd>lua require'dap'.repl.toggle()<CR>";
      options.desc = "Toggles the DAP REPL";

      mode = [
        "n"
        "v"
      ];
    }
    {
      key = "<C-a>";
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
    image.enable = true;
    
    dap = {
      enable = true;

      extensions = {
        dap-ui = {
          enable = true;
        };
      };

      configurations = {
        java = [
          {
            name = "Attach Debugger";
            type = "java";
            request = "attach";
            hostName = "localhost";
            port = 5005;
          }
          {
            name = "Launch Debug";
            type = "java";
            request = "launch";
          }
        ];
      };
    };

    lsp = {
      enable = true;
      inlayHints = true;

      keymaps = {
        diagnostic = {
          "<leader>d" = "open_float";
        };
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

        bashls = {
          enable = true;
        };

        jdtls = {
          onAttach.function = ''
            require('jdtls.dap').setup_dap({ hotcodereplace = 'auto' })
            require('jdtls.dap').setup_dap_main_class_configs()
            vim.lsp.codelens.refresh()
          '';
        };
      };
    };

    nvim-jdtls = {
      enable = true;
      configuration = "${config.home.homeDirectory}/.config/jdtls/config";
      data = mkRaw "'${config.home.homeDirectory}/.local/share/jdtls/workspace' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')";

      initOptions = {
        bundles = mkRaw "{ vim.fn.glob('${./.}/com.microsoft.java.debug.plugin-*.jar'), }";
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
            starThreshold = 5;
            staticStarThreshold = 5;
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
      };

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
