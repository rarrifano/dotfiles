DOTFILES := $(shell pwd)
PACKAGES := alacritty bash git mise nvim pi tmux
STOW     := stow --dotfiles --no-folding -t $(HOME) -d $(DOTFILES)

.PHONY: stow unstow lint fmt lint-bash lint-lua

stow:
	$(STOW) $(PACKAGES)

unstow:
	$(STOW) -D $(PACKAGES)

lint: lint-bash lint-lua
	! grep -rInE ' +$$' $(PACKAGES)
	! grep -rInP '^(\t+ +|\t* +\t+)' $(PACKAGES)

fmt:
	grep -rlE ' +$$' $(PACKAGES) | xargs -r sed -i -E 's/ +$$//'
	stylua $(PACKAGES)

lint-bash:
	shellcheck bash/dot-bashrc $$(find $(PACKAGES) -name '*.sh')

lint-lua:
	stylua --check $(PACKAGES)
