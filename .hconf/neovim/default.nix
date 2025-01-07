{ config
, lib
, pkgs }:

#TODO: why doesn't friendly snippets work?

let
  mkRaw = config.lib.nixvim.mkRaw;
in {
  enable = true;
  viAlias = true;
  vimAlias = true;
  enableMan = true;

  nixpkgs.pkgs = pkgs;

  opts = {
    number = true;
    relativenumber = true;
    expandtab = true;
    smartcase = true;
    incsearch = true;
    breakindent = true;
    list = true;
    showmode = false;
    shiftwidth = 4;
    tabstop = 4;
    scrolloff = 8;
    clipboard = "unnamedplus";

    listchars = {
      multispace = "⋅";
      trail = "•";
      extends = "❯";
      precedes = "❮";
    };
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
      key = "<leader>c";
      action = "<cmd>LazyGit<CR>";
      options.desc = "Opens lazygit";
    }
    {
      key = "<leader>n";
      action = "<cmd>Navbuddy<CR>";
      options.desc = "Opens the symbol navigation window";
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
      key = "<leader>Q";
      action = "<cmd>BufferCloseAllButCurrent<CR>";
      options.desc = "Closes all other tabs";
    }
    {
      key = "<leader>EE";
      action = "<cmd>execute \"bufdo w | BufferClose\" | q<CR>";
      options.desc = "Saves all open tabs individually and then quits";
    }
    {
      key = "<leader>j";
      action = "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR })<CR>";
      options.desc = "Hop forwards";
    }
    {
      key = "<leader>J";
      action = "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR })<CR>";
      options.desc = "Hop backwards";
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
    {
      key = "<C-c>";
      action = "<cmd>MurdenToggle<CR>";
      options.desc = "Toggles the advanced find-and-replace window";

      mode = [
        "n"
        "v"
        "i"
      ];
    }
  ];

  autoCmd = [
    {
      event = [ "BufWritePre" ];
      pattern = [ "*.java" ];
      callback = mkRaw ''
        function()
          pcall(vim.lsp.buf.format)
        end
      '';
    }
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
      event = [ "BufEnter" ];
      pattern = [ "*.axaml" "*.xaml" ];
      command = "set filetype=xml";
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
    gitignore.enable = true;
    compiler.enable = true;
    lsp-lines.enable = true;
    lsp-signature.enable = true;
    specs.enable = true;
    barbar.enable = true;
    web-devicons.enable = true;
    hmts.enable = true;
    lazygit.enable = true;
    nvim-surround.enable = true;
    git-conflict.enable = true;
    treesitter.enable = true;
    treesitter-context.enable = true;
    hop.enable = true;
    image.enable = true;
    direnv.enable = true;
    twilight.enable = true;
    rainbow-delimiters.enable = true;
    render-markdown.enable = true;
    telescope.enable = true;
    intellitab.enable = true;
    inc-rename.enable = true;
    illuminate.enable = true;
    comment.enable = true;
    dressing.enable = true;
    neocord.enable = true;
    notify.enable = true;
    friendly-snippets.enable = true;

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
          cs = "code_action";
          rn = "rename";
          "<C-k>" = "signature_help";
        };
      };

      onAttach = ''
        pcall(vim.lsp.codelens.refresh)
      '';

      servers = {
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

        csharp_ls = {
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

    lazy = {
      enable = true;

      plugins = [
        # {
        #   name = "scalameta/nvim-metals";
        #   enabled = true;
        #   pkg = pkgs.vimPlugins.nvim-metals;
        #   dependencies = [
        #     pkgs.vimPlugins.plenary-nvim
        #   ];
        #   ft = [
        #     "scala"
        #     "sbt"
        #     "java"
        #   ];
        #   opts = mkRaw ''
        #     function()
        #       local metals_config = require("metals").bare_config()
        #       metals_config.on_attach = function(client, bufnr)
        #         -- your on_attach function
        #       end
        #
        #       return metals_config
        #     end
        #   '';
        #   config = mkRaw ''
        #     function(self, metals_config)
        #       local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
        #       vim.api.nvim_create_autocmd("FileType", {
        #         pattern = self.ft,
        #         callback = function()
        #           require("metals").initialize_or_attach(metals_config)
        #         end,
        #         group = nvim_metals_group,
        #       })
        #     end
        #   '';
        # }
      ];
    };

    coq-nvim = {
      enable = true;
      installArtifacts = true;

      settings = {
        xdg = true;
        auto_start = "shut-up";
        keymap.recommended = false;
      };
    };

    navbuddy = {
      enable = true;
      lsp.autoAttach = true;

      mappings = {
        "<DOWN>" = "next_sibling";
        "<UP>" = "previous_sibling";
        "<LEFT>" = "parent";
        "<RIGHT>" = "children";
      };
    };

    muren = {
      enable = true;
      #TODO: probably needs configuring
    };

    lightline = {
      enable = true;

      settings = {
        colorscheme = "catppuccin";
      };
    };

    autoclose = {
      enable = true;

      options = {
        autoIndent = true;
        pairSpaces = true;
        disableCommandMode = true;
      };
    };

    hardtime = {
      enable = true;

      settings = {
        max_time = 0;

        disabled_keys = {
          "<Down>" = mkRaw "{}";
          "<Left>" = mkRaw "{}";
          "<Right>" = mkRaw "{}";
          "<Up>" = mkRaw "{}";
        };
      };
    };

    gitsigns = {
      enable = true;

      settings = {
        current_line_blame = true;
        current_line_blame_opts.virt_text_pos = "right_align";
        diff_opts.algorithm = "minimal";
      };
    };

    luasnip = {
      enable = true;

      fromVscode = [
        {
          lazyLoad = false;
        }
      ];
    };

    indent-blankline = {
      enable = true;

      settings = {
        whitespace = {
          remove_blankline_trail = false;
        };

        scope = {
          show_start = true;
          show_exact_scope = true;
          show_end = false;
        };

        exclude = {
          filetypes = [
            "yaml"
            "yml"
          ];
        };
      };

      luaConfig.post = /* lua */ ''
        local highlight = {
            "RainbowRed",
            "RainbowYellow",
            "RainbowBlue",
            "RainbowOrange",
            "RainbowGreen",
            "RainbowViolet",
            "RainbowCyan",
        }

        local hooks = require "ibl.hooks"
        -- create the highlight groups in the highlight setup hook, so they are reset
        -- every time the colorscheme changes
        hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
            vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
            vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
            vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
            vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
            vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
            vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
            vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
        end)

        vim.g.rainbow_delimiters = { highlight = highlight }
        require("ibl").setup { scope = { highlight = highlight } }

        hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
      '';
    };
  };
}
