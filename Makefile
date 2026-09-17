DOTFILES := $(CURDIR)
PACKAGES := bash git vim pi
STOW     := stow --dotfiles --no-folding -t $(HOME) -d $(DOTFILES)

.PHONY: stow unstow restow gnome

stow:
	$(STOW) $(PACKAGES)

unstow:
	$(STOW) -D $(PACKAGES)

restow:
	$(STOW) -R $(PACKAGES)

gnome:
	sh gnome/apply-settings.sh
