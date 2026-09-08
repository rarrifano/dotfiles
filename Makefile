DOTFILES := $(CURDIR)
PACKAGES := bash git vim pi
STOW     := stow --dotfiles --no-folding -t $(HOME) -d $(DOTFILES)

.PHONY: stow unstow restow lint

stow:
	$(STOW) $(PACKAGES)

unstow:
	$(STOW) -D $(PACKAGES)

restow:
	$(STOW) -R $(PACKAGES)

lint:
	@find $(PACKAGES) -type f -exec sed -i 's/[ \t]*$$//' {} +
	$(STOW) --simulate $(PACKAGES)
