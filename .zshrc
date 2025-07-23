# .zshrc

# Put your personal configurations in ~/.zcustom file and they will
# be sourced at the end
ZCUSTOM_FILE="$HOME/.zcustom"

############################# FUNCTIONS #############################

# create a folder (if it does not exist) and cd to it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# check if a command exists
exists() {
    command -v "$1" >/dev/null 2>&1
}

# used by this script to notify what is being installed
info() {
    local BLUE='\033[1;36m'
    local NO_COLOR='\033[0m'
    echo
    echo "${BLUE}${1}${NO_COLOR}"
    echo
}

# used by this script to warn the user
warn() {
    local YELLOW='\033[1;33m'
    local NO_COLOR='\033[0m'
    echo
    echo "${YELLOW}${1}${NO_COLOR}"
    echo
}

############################## OH-MY-ZSH ##############################

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"

# Install oh-my-zsh if not installed (preserving .zshrc file)
if [ ! -d $ZSH ]; then
    info "Installing oh-my-zsh..."
    curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --keep-zshrc
fi

############################## OH-MY-ZSH PLUGINS ##############################

# Function to install custom plugins if not already present
setup_custom_plugin() {
    local plugin_path=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$1
    local plugin_url=$2

    if [ ! -d $plugin_path ]; then
        info "Installing $plugin_url..."
        git clone $plugin_url $plugin_path
    fi
}

# Install custom plugins
setup_custom_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
setup_custom_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting

# Configure oh-my-zsh plugins
# Note: zsh-syntax-highlighting should always be last for best performance
plugins=(
    git
    # order below is important
    zsh-navigation-tools
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# Disable zsh_theme as we use starship
ZSH_THEME=""

# Initialize Oh My Zsh (must come after plugins are set)
source $ZSH/oh-my-zsh.sh

############################## ALIAS ##############################
# alias should be defined after sourcing oh-my-zsh
export STARSHIP_CONFIG_FILE="$HOME/.config/starship.toml"

alias cls="clear"
alias zshconfig="code ~/.zshrc"
alias starshipconfig="code $STARSHIP_CONFIG_FILE"
alias zcustomconfig="code $ZCUSTOM_FILE"

alias starship-preset-nerd-fonts="starship preset nerd-font-symbols > $STARSHIP_CONFIG_FILE"
alias starship-preset-no-nerd-font="starship preset no-nerd-font > $STARSHIP_CONFIG_FILE"
alias starship-preset-plain-text="starship preset plain-text-symbols > $STARSHIP_CONFIG_FILE"
alias starship-preset-custom="cp $HOME/.dotfiles/starship.toml $STARSHIP_CONFIG_FILE"

if [[ "$OSTYPE" == "darwin"* ]]; then
    alias ll="ls -laG"
else
    alias ll="ls -la --color=auto"
fi

alias update_dotfiles="curl -sL https://raw.githubusercontent.com/lluissm/dotfiles/main/install.sh | sh"

############################## DEV TOOLS ##############################
# CUSTOM_TOOLS_DIR
export CUSTOM_TOOLS_DIR="$HOME/.local/bin"
if [ ! -d $CUSTOM_TOOLS_DIR ]; then
    mkdir -p $CUSTOM_TOOLS_DIR
fi
export PATH="$CUSTOM_TOOLS_DIR:$PATH"

# DIRENV (per directory env vars via .envrc): https://direnv.net/
update-direnv() {
    export bin_path=$CUSTOM_TOOLS_DIR
    info "Installing direnv..."
    curl -sfL https://direnv.net/install.sh | bash
    unset bin_path
}
if [ ! -f "$CUSTOM_TOOLS_DIR/direnv" ]; then
    update-direnv
fi
eval "$(direnv hook zsh)"

# ZOXIDE (smarter cd command): https://github.com/ajeetdsouza/zoxide
update-zoxide() {
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
}
if [ ! -f "$CUSTOM_TOOLS_DIR/zoxide" ]; then
    update-zoxide
fi
eval "$(zoxide init zsh)"

# HOMEBREW (package manager for OSX): https://brew.sh/
if [[ "$OSTYPE" == "darwin"* ]]; then
    export PATH="$PATH:$HOME/bin:/usr/local/bin:/opt/homebrew/bin"
    if ! exists brew; then
        info "Installing brew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    install-fonts() {
        info "Installing cash-fonts..."
        brew tap homebrew/cask-fonts

        info "Installing jetbrains mono fonts..."
        brew install font-jetbrains-mono-nerd-font
        brew install font-jetbrains-mono
    }
fi

# GIT_UTILS (clone and update git repos in bulk): https://github.com/lluissm/git-utils
export GIT_UTILS_DIR="$HOME/.git-utils"
if [ ! -d $GIT_UTILS_DIR ]; then
    info "Installing git-utils..."
    git clone https://github.com/lluissm/git-utils.git $GIT_UTILS_DIR
fi
source $GIT_UTILS_DIR/bulk-utils.sh

############################## PROMPT ##############################

# Starship prompt
update-starship() {
    info "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh
}
if ! exists starship; then
    update-starship
fi
eval "$(starship init zsh)"

############################## CUSTOM ##############################

# Source custom configuration
if [ -f $ZCUSTOM_FILE ]; then
    source $ZCUSTOM_FILE
fi
