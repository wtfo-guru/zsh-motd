# Bash / Ubuntu MOTD for Zsh, but cooler
# This script is partly based on the default /etc/profile.d/update-motd.sh found in Ubuntu 20.04.
# shellcheck shell=bash

stamp="${HOME}/.motd_shown"
always="${HOME}/.update-mode.always"

# Make sure perl is installed. It usually is, but just in case
PERL_INSTALLED=0
if hash perl; then
    PERL_INSTALLED=1
fi

random_word() {
    perl -e 'open IN, "</usr/share/dict/words";rand($.) < 1 && ($n=$_) while <IN>;print $n'
}

rainbow_dino() {
    ( hash cowsay 2>/dev/null && cowsay -n -f stegosaurus || cat ) |
    ( hash lolcat 2>/dev/null && lolcat || cat )
}

rainbow_dragon() {
    ( hash cowsay 2>/dev/null && cowsay -n -f dragon || cat ) |
    ( hash lolcat 2>/dev/null && lolcat || cat )
}

fortune_text() {
    ( hash fortune 2>/dev/null && fortune || printf "Hey $USER\n" )
}

print_header() {
    # Custom message
    if [ ! -z ${ZSH_MOTD_CUSTOM+x} ]; then
      echo $ZSH_MOTD_CUSTOM |
      ( hash figlet 2>/dev/null && figlet || cat ) |
      rainbow_dino

    # Word of the day
    elif [ ! -z ${ZSH_MOTD_WOTD+x} ] && [ $PERL_INSTALLED -eq 1 ]; then
      random_word |
      ( hash figlet 2>/dev/null && figlet || cat ) |
      rainbow_dino
    elif hash neofetch 2>/dev/null ; then
      neofetch
    # Default
    else
        fortune_text | rainbow_dragon
    fi
}

MINUTE_TIME=$(date +%M)
TRES=$((MINUTE_TIME%3))
DOS=$((MINUTE_TIME%2))

# Linux MOTD - once a day
if [ -d /etc/update-motd.d ] && [ ! -e "$HOME/.hushlogin" ] && [ -z "$MOTD_SHOWN" ] && [ "$TRES" != "0" ] && [ "$DOS" != "0" ]; then
    [ $(id -u) -eq 0 ] || SHOW="--show-only"
    update-motd $SHOW
    if [ ! -e "$always" ]; then
      touch $stamp
      export MOTD_SHOWN=update-motd
    fi
# ZSH MOTD - once every 3 hours
elif [ ! -z ${ZSH_MOTD_ALWAYS+x} ] || [ "$DOS" = "0" ]; then
    print_header
    touch $stamp
elif [ $PERL_INSTALLED -eq 1 ]; then
    echo
    # random_word | ( hash lolcat 2>/dev/null && lolcat || cat )
    fortune_text | rainbow_dragon
fi
