# =============================================================================
# ZSH CONFIGURATION
# =============================================================================

# --- Environment ---
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"

# --- History ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory
setopt incappendhistory

# --- Aliases ---
alias c='clear'
alias ls='eza -lh --group-directories-first --icons=auto'
alias ll='eza -al --group-directories-first --icons=always'
alias lt='eza -a --tree --level=2 --icons=always'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias rm='trash-put' # Safer rm
alias update='yay -Syu'
alias pf='fastfetch'

# --- Custom Functions & MyBash Aliases ---
alias yayf="yay -Slq | fzf --multi --preview 'yay -Sii {1}' --preview-window=down:75% | xargs -ro yay -S"
alias home='cd ~'
alias bd='cd "$OLDPWD"'
alias rmd='/bin/rm --recursive --force --verbose'

function whatsmyip() {
    if command -v ip &> /dev/null; then
        echo -n "Internal IP: "
        ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | cut -d/ -f1 | head -n 1
    fi
    echo -n "External IP: "
    curl -s ifconfig.me
    echo
}

function hb() {
    if [ $# -eq 0 ]; then
        echo "No file path specified."
        return
    elif [ ! -f "$1" ]; then
        echo "File path does not exist."
        return
    fi
    uri="http://bin.christitus.com/documents"
    response=$(curl -s -X POST -d @"$1" "$uri")
    key=$(echo $response | jq -r '.key')
    url="http://bin.christitus.com/$key"
    echo "Hastebin URL: $url"
}

# --- Init Integrations ---
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

if command -v fzf &>/dev/null; then
    source <(fzf --zsh)
fi

# --- Plugins (Autosuggestions & Syntax Highlighting) ---
# Arch Linux pacman packages
if [ -f "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [ -f "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f "/usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]; then
    source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
elif [ -f "$HOME/.oh-my-zsh/custom/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]; then
    source "$HOME/.oh-my-zsh/custom/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
fi

# --- Startup ---
# Show fastfetch only in interactive terminal sessions
if [[ $(tty) == *"pts"* ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
    fastfetch
    export _FASTFETCH_SHOWN=1
fi

function clear_fastfetch_on_first_cmd() {
    if [[ "$_FASTFETCH_SHOWN" -eq 1 ]]; then
        clear
        export _FASTFETCH_SHOWN=0
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec clear_fastfetch_on_first_cmd