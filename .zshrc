# If you come from bash you might have to change your $PATH.
#export PATH=$HOME/bin:$HOME/bin/util:/usr/local/bin:$PATH
export PATH=$PATH:$(printf '%s:' ${HOME}/bin/*/)

# Path to your oh-my-zsh installation.
export ZSH="/home/enovid/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="theunraveler"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
 COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder
# Set fzf installation directory path
export FZF_BASE=/usr/bin/fzf

# Uncomment the following line to disable fuzzy completion
# export DISABLE_FZF_AUTO_COMPLETION="true"

# Uncomment the following line to disable key bindings (CTRL-T, CTRL-R, ALT-C)
# export DISABLE_FZF_KEY_BINDINGS="true"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    fzf
    asdf
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias timer="python3 .i3/timer_bar.py"
alias zf="zathura --fork"
alias z="zathura" 
alias kc="kitty-cat"
alias unlock='export BW_SESSION=$(bw unlock --raw)'
alias gs='git status'
alias c='config'
alias cs='config status'
alias ca='config add'
alias ccmsg='config commit -m'
alias td='termdown'
alias ppy='java -jar ~/repos/generative-art/processing-py.jar'
# Open mpv in focused window
#alias mpv='mpv --wid=$(xdotool getwindowfocus)'
alias b='bluetoothctl'
alias n='nvim'
alias f='rga-fzf'
alias d='cd ~/courses/data100/'
alias y='youtube-dl'
alias j='jupyter notebook'
# Temporary workflow aliases
alias j1='cd /home/enovid/repos/luggage-comparison/ && jupyter notebook'
alias j2='cd /home/enovid/repos/thirdparty/fastai/nbs/ && jupyter notebook'
alias p='cd /home/enovid/repos/luggage-comparison/'
alias p1='cd /home/enovid/repos/thirdparty/fastai/nbs/'

# FZF Config
# follow symbolic links and don't exclude hidden file
FD_OPTIONS="--hidden --follow --exclude .git --exclude node_modules --exclude .DS_Store --exclude '*.swp' --exclude Library --exclude private --exclude .virtualenvs"
export FZF_DEFAULT_COMMAND="fd --type f $FD_OPTIONS"
export FZF_CTRL_T_COMMAND="fd --type d $FD_OPTIONS"
export FZF_ALT_C_COMMAND="fd $FD_OPTIONS"
export FZF_DEFAULT_OPTS="--bind Ctrl-u:preview-page-up,Ctrl-d:preview-page-down,Ctrl-y:preview-up,Ctrl-e:preview-down"
export FZF_COMPLETION_TRIGGER=','
# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# Use [rga](https://github.com/phiresky/ripgrep-all) with fzf
rga-fzf() {
	RG_PREFIX="rga --files-with-matches"
	local file
	file="$(
		FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
			fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
				--phony -q "$1" \
				--bind "change:reload:$RG_PREFIX {q}" \
				--preview-window="70%:wrap"
	)" &&
	echo "opening $file" &&
	xdg-open "$file"
}

# Completion for Kitty terminal
autoload -Uz compinit
compinit
# Completion for kitty
kitty + complete setup zsh | source /dev/stdin

# Track dotfiles: https://www.atlassian.com/git/tutorials/dotfiles
alias config='/usr/bin/git --git-dir=/home/enovid/.cfg/ --work-tree=/home/enovid'

# Allow RubyGems to be executed
export PATH=$PATH:$(ruby -e 'puts Gem.user_dir')/bin

# Use Nvim as manpager `:h Man`
export MANPAGER='nvim +Man!'
export MANWIDTH=999

# gpg-agent
export GPG_TTY=$(tty)
export BROWSER=/usr/bin/google-chrome-stable

# PyTorch development
export LRU_CACHE_CAPACITY=1

# Python tools
export PATH=$PATH:$HOME/.local/bin
fpath=(~/.zsh.d/ $fpath)
