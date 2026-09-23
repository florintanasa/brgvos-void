# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

# add a path with some binary
export PATH="$HOME/.local/bin:$PATH"

# some alias commands
alias ls='ls --color=auto'
alias lls='eza -logh --icons --group-directories-first'
alias dufs='duf --hide special'

# color for less pager
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# 5. Advanced Terminal Console (TTY) and Theme Engine routing
CURRENT_LANGUAGE=$(locale | grep LANG | awk -F "=" '{print $2}')
# For console tty
if [ "$TERM" = "linux" ]; then
    setfont ter-v22b
    PS1='\[\e[1;31m\][brgvos] \[\e[1;34m\]\u@\h \[\e[1;32m\]\w\[\e[0m\]\$ '

    if [ "$CURRENT_LANGUAGE" = "zh_TW.UTF-8" ] || [ "$(tty)" = "/dev/tty6" ]; then
        fbterm -- bash -c 'export TERM=fbterm; exec "$SHELL"'
    fi
else
    # For X11/Wayland/TMUX
    if command -v oh-my-posh >/dev/null 2>&1; then
        eval "$(oh-my-posh init bash --config /usr/share/oh-my-posh/themes/multiverse-neon.omp.json)"
    fi
fi

# LLM's home configuration. Is the path where the models is stored
# User is necessary to be part from group `llm` to have rights on it

export OLLAMA_MODELS="/var/lib/llms/ollama"
export HF_HOME="/var/lib/llms/huggingface"
export FLM_MODEL_PATH="/var/lib/llms/flm"

