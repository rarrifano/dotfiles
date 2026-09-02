DOTFILES := $(shell pwd)
PACKAGES := alacritty bash git nvim pi tmux
STOW     := stow --dotfiles --no-folding -t $(HOME) -d $(DOTFILES)

.PHONY: stow unstow lint

stow:
	$(STOW) $(PACKAGES)

unstow:
	$(STOW) -D $(PACKAGES)

lint:
	grep -rlE ' +$$' $(PACKAGES) | xargs -r sed -i -E 's/ +$$//'
	! grep -rInE ' +$$' $(PACKAGES)
	! grep -rInP '^(\t+ +|\t* +\t+)' $(PACKAGES)
	bash -n bash/dot-bashrc
