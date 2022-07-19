# .zshrc

############################# FUNCTIONS #############################

# create a folder (if it does not exist) and cd to it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# check if a command exists
exists() {
    command -v "$1" >/dev/null 2>&1
}

############################## OH-MY-ZSH ##############################

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"

# Install oh-my-zsh if not installed (preserving .zshrc file)
if [ ! -d $ZSH ]; then
    curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --keep-zshrc
fi

setup_custom_plugin() {
    local plugin_path=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$1
    local plugin_url=$2

    if [ ! -d $plugin_path ]; then
        git clone $plugin_url $plugin_path
    fi
}

# Install custom plugins
setup_custom_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
setup_custom_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting

# Configure oh-my-zsh plugins
plugins=(
    gh
    git
    gitignore
    direnv
    # order below is important
    zsh-navigation-tools
    zsh-syntax-highlighting
    zsh-autosuggestions
)

# Add dnf plugin only if dnf package manager is installed (for fedora linux)
if [[ "$OSTYPE" == "linux"* ]]; then
    if exists dnf; then
        plugins+=(dnf)
    fi
fi

# Disable zsh_theme as we use starship
ZSH_THEME=""

source $ZSH/oh-my-zsh.sh

############################## ALIAS ##############################
# alias should be defined after sourcing oh-my-zsh

alias zshconfig="code ~/.zshrc"
alias starshipconfig="code ~/.config/starship.toml"
alias cls="clear"
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias ll="ls -laG"
else
    alias ll="ls -la --color=auto"
fi
alias update_dotfiles="curl -sL https://raw.githubusercontent.com/lluissm/dotfiles/main/install.sh | sh"

############################## DEV TOOLS ##############################

# DIRENV (per directory env vars via .envrc): https://direnv.net/
export DIRENV_DIR="$HOME/.direnv"
if [ ! -d $DIRENV_DIR ]; then
    mkdir -p $DIRENV_DIR
    # direnv installer looks for bin_path env
    export bin_path=$DIRENV_DIR
    curl -sfL https://direnv.net/install.sh | bash
    unset bin_path
fi
export PATH="$DIRENV_DIR:$PATH"
eval "$(direnv hook zsh)"

# NVM (node version manager): https://github.com/nvm-sh/nvm
export NVM_DIR="$HOME/.nvm"
if [ ! -d $NVM_DIR ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | sh
fi
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# DENO (runtime for js/ts): https://deno.land/
export DENO_DIR="$HOME/.deno"
if [ ! -d $DENO_DIR ]; then
    # deno installer looks for DENO_INSTALL env
    export DENO_INSTALL=$DENO_DIR
    curl -fsSL https://deno.land/install.sh | sh
    unset DENO_INSTALL
fi
export PATH="$DENO_DIR/bin:$PATH"

# GVM (Go version manager): https://github.com/moovweb/gvm
export GVM_DIR="$HOME/.gvm"
if [ ! -d $GVM_DIR ]; then
    bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
fi
[ -s "$GVM_DIR/scripts/gvm" ] && \. "$GVM_DIR/scripts/gvm"

# RUST (programming language): https://www.rust-lang.org/
export CARGO_DIR="$HOME/.cargo"
if [ ! -d $CARGO_DIR ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi
[ -s "$CARGO_DIR/env" ] && \. "$CARGO_DIR/env"

# HOMEBREW (package manager for OSX): https://brew.sh/
if [[ "$OSTYPE" == "darwin"* ]]; then
    export PATH="$PATH:$HOME/bin:/usr/local/bin:/opt/homebrew/bin"
    if ! exists brew; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
fi

# GIT_UTILS (clone and update git repos in bulk): https://github.com/lluissm/git-utils
export GIT_UTILS_DIR="$HOME/.git-utils"
if [ ! -d $GIT_UTILS_DIR ]; then
    git clone https://github.com/lluissm/git-utils.git $GIT_UTILS_DIR
fi
source $GIT_UTILS_DIR/bulk-utils.sh

############################## PROMPT ##############################

# Starship prompt
if ! exists starship; then
    curl -sS https://starship.rs/install.sh | sh
fi

eval "$(starship init zsh)"

############################## CUSTOM ##############################

# Put your personal configurations in ~/.zcustom file and they will
# be loaded automatically
ZCUSTOM_FILE="$HOME/.zcustom"
if [ -f $ZCUSTOM_FILE ]; then
    source $ZCUSTOM_FILE
fi
