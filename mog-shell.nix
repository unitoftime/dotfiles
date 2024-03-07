{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    nativeBuildInputs = with pkgs; [
      gcc
      gdb
      gnumake
      # https://www.reddit.com/r/NixOS/comments/lqda7w/mingw/?rdt=34903
      # pkgsCross.mingw32.buildPackages.gcc
      pkgsCross.mingwW64.buildPackages.gcc

      pkgs.imagemagick

      alsa-lib

      mesa
      mesa.dev
      glfw

      # xorg.libX11
      # xorg.libXft
      # xorg.libXinerama
      # xorg.libXcursor
      # xorg.libXrender
      # xorg.libXrandr
      # xorg.libXi
      # libGL
      # libglvnd
      # xorg.xorgproto

      xorg.libX11.dev
      xorg.libXft.dev
      xorg.libXinerama.dev
      xorg.libXcursor.dev
      xorg.libXrender.dev
      xorg.libXrandr.dev
      xorg.libXi.dev
      libGL.dev
      libglvnd.dev

      # This might need to be at the end?
      pkg-config
    ];
}