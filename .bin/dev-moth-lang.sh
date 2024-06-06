#!/usr/bin/env bash

cd ~/RiderProjects/moth-lang
export NIXPKGS_ALLOW_UNFREE=1
nix-shell -p vscode jetbrains.rider --run "code ~/VSCodeProjects/moth.code-workspace &
  rider ./moth-lang.sln"
