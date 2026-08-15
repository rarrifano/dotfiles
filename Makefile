DOTFILES := $(shell pwd)
PACKAGES := bash pi tmux vim
STOW     := stow --no-folding -t $(HOME) -d $(DOTFILES)

.PHONY: stow unstow

stow:
	$(STOW) $(PACKAGES)

unstow:
	$(STOW) -D $(PACKAGES)
