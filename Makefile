# `make` sets this machine up, or brings it up to date: every step is safe to rerun.
#
# New machine, with another machine already set up:
#   1. sudo pacman -S --needed syncthing make && systemctl --user enable --now syncthing
#   2. Open http://localhost:8384, "Add Remote Device" with the other machine's ID (Actions >
#      Show ID there) and tick "Auto Accept". On the other machine, accept the new device,
#      then run `make syncthing` there to share every folder with it.
#   3. Once ~/dotfiles has arrived, run `make` in it.
# With no other machine: install git and make, add an SSH key to GitHub, clone this repo to
# ~/dotfiles and run `make`. private/ is not in git, so start it again from scratch.

TED_PKGBUILD := https://raw.githubusercontent.com/unitoftime/ted/master/packaging/arch/PKGBUILD
TED_BUILD    := $(HOME)/.cache/ted-pkg
DCONF        := private/dconf-settings.ini
DCONF_STAMP  := $(HOME)/.cache/dotfiles/dconf-loaded

.PHONY: all packages rust stow ted syncthing dconf save-dconf

all: packages rust stow ted syncthing dconf

# The keyring goes first so packages signed by new keys verify.
packages:
#	reflector --verbose -l 200 -n 20 -p http --sort rate --save /etc/pacman.d/mirrorlist
	sudo pacman -Sy --needed archlinux-keyring
	sudo pacman -Su --needed `<./depac.conf`

rust: packages
	rustup default stable
	rustup update stable
	rustup component add rust-analyzer

# Links home/ (public) and private/home/ (synced, never pushed) into ~.
# --no-folding: link files, never whole directories, so apps writing state next to
# their config (e.g. ~/.config/ted/history) don't write into this repo.
# -R also drops links to files since removed.
stow: packages
	stow --no-folding -R home
	[ ! -d private/home ] || stow -d private -t $(HOME) --no-folding -R home

# Builds the pushed ted outside any synced folder, so build files never sync.
ted: rust stow
	mkdir -p $(TED_BUILD)
	curl -fsSL -o $(TED_BUILD)/PKGBUILD $(TED_PKGBUILD)
	cd $(TED_BUILD) && makepkg -si --needed

syncthing: packages
	systemctl --user enable --now syncthing.service
	./syncthing/setup.sh

# Loads the saved GNOME settings only when they're newer than what this machine last
# loaded, so a tweak made here survives until some machine saves new settings.
dconf: $(if $(wildcard $(DCONF)),$(DCONF_STAMP))
$(DCONF_STAMP): $(DCONF)
	dconf load / < $<
	@mkdir -p $(@D) && touch $@

# Saves this machine's GNOME settings; Syncthing carries them to the other machines.
save-dconf:
	@mkdir -p $(dir $(DCONF)) $(dir $(DCONF_STAMP))
	dconf dump / > $(DCONF)
	@touch $(DCONF_STAMP)
