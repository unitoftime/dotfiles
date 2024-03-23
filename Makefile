all:

deploy-stow:
	stow home

deploy-nixos:
	sudo cp ./nixos/configuration.nix /etc/nixos/configuration.nix
	sudo nixos-rebuild switch

deploy-arch:
	sudo pacman -Syu
	sudo yay -Syu
	sudo pacman -S `<./depac.conf`

deploy-dconf:
	dconf load / < dconf-settings.ini
get-dconf:
	dconf dump / > dconf-settings.ini
