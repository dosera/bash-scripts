# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

#-------------------------
# Aliases
#-------------------------

# ls colors
alias ls="ls -h --color=auto"
LS_COLORS='di=1;104'
export LS_COLORS
# nano with undo @ alt + u
alias nano="nano -u"
# cached mplayer
alias mplayer='mplayer -cache 8192'
# ll (list all human-readable in list format and directories with a / in the end)
alias ll='ls -lhaF'
# tab completion for sudo
complete -cf sudo
# shred default with 100 overrides and delete
alias shred='shred -uzvn 100'

#-------------------------
# Functions
#-------------------------

# include the truecrypt mount function
source /home/tasse/.i3/Scripts/truecrypt_mounter.sh

#-------------------------
# MISC
#-------------------------

# make the linewrapping such that, if a line is too long it is cut, but it respawns after there is space available again
for (( i=1; i<=$LINES; i++ )); do echo; done; clear
# editor
export EDITOR="$(if [[ -n $DISPLAY ]]; then echo 'subl3'; else echo 'nanoöö'; fi)"	# gedit, vim 
# PS1
export PS1='\[\033[01;32m\]\u@\h \[\033[00;31m\]\W \$ \[\033[00m\]'

