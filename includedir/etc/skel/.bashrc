# .bashrc

# add path to user bin app - for deskmom
export PATH="$HOME/.local/bin:$PATH"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# some alias commands
alias ls='ls --color=auto'
alias lls='eza -logh --icons --group-directories-first'
alias dufs='duf --hide special'
# whith text color for terminal prompt
#PS1='[\u@\h \W]\$ '
# green text color for teminal prompt
PS1='\[\e[32m\]\u@\h:\w\$\[\e[m\] ' 
# set color for less pager - now man looks nice
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'
