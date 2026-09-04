DOTFILES := $(shell pwd)
PACKAGES := bash git vim pi
STOW     := stow --dotfiles --no-folding -t $(HOME) -d $(DOTFILES)

.PHONY: stow unstow

stow:
	$(STOW) $(PACKAGES)

unstow:
	$(STOW) -D $(PACKAGES)
