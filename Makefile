DOTFILES := $(CURDIR)
PACKAGES := bash git vim pi
STOW     := stow --dotfiles --no-folding -t $(HOME) -d $(DOTFILES)

.PHONY: stow unstow restow gnome fmt

stow:
	$(STOW) $(PACKAGES)

unstow:
	$(STOW) -D $(PACKAGES)

restow:
	$(STOW) -R $(PACKAGES)

gnome:
	sh gnome/apply-settings.sh

fmt:
	@find . -path './.git' -prune -o -type f -exec \
		awk 'length > 80 { \
			printf "%s:%d: %d characters\n", \
				FILENAME, FNR, length; \
			bad = 1 \
		} END { exit bad }' {} +
