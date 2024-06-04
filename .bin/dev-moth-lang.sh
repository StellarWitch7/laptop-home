#!/usr/bin/env bash

cd ~/RiderProjects/moth-lang
code ~/VSCodeProjects/moth.code-workspace &
nix-shell --run rider
