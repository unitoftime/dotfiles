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

# Install yay
# pacman -S --needed git base-devel
# git clone https://aur.archlinux.org/yay-bin.git
# cd yay-bin
# makepkg -si
