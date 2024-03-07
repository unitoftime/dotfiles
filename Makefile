all:

setup-stow:
	stow home

setup-nixos:
	cp ./nixos/configuration.nix /etc/nixos/configuration.nix
get-nixos:
	cp /etc/nixos/configuration.nix ./nixos/

get-shell:
	cp ~/workspace/mog/default.nix ./mog-shell.nix

setup-dconf:
	dconf load / < dconf-settings.ini
get-dconf:
	dconf dump / > dconf-settings.ini
