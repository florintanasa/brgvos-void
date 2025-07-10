# .bashrc

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
