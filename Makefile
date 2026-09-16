DOTFILES := $(CURDIR)
PACKAGES := bash git vim pi
STOW     := stow --dotfiles --no-folding -t $(HOME) -d $(DOTFILES)

.PHONY: stow unstow restow fmt lint

stow:
	$(STOW) $(PACKAGES)

unstow:
	$(STOW) -D $(PACKAGES)

restow:
	$(STOW) -R $(PACKAGES)

fmt:
	@find $(PACKAGES) -type f -exec sed -i 's/[ \t]*$$//' {} +

lint:
	@! grep -RIn '[[:space:]]$$' $(PACKAGES)
	$(STOW) --simulate $(PACKAGES)
