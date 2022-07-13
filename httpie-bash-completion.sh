_httpie() 
{
    local CMD=${COMP_WORDS[0]}
    local CUR=${COMP_WORDS[COMP_CWORD]}
    local PREV=${COMP_WORDS[COMP_CWORD-1]}
    local IFS=$' \t\n' WORDS
    local VER=$( stat -c %Y `which http` )

    if [ "${CUR:0:1}" = "-" ]; then
        if [ -z "$_httpie" -o "$VER" != "${_httpie%%$'\n'*}" ]; then
            _httpie=$VER$'\n'$( $CMD --help | sed -En '/^  -/p' | grep -Eo -- '-[[:alnum:]-]+' )
        fi
        WORDS=${_httpie#*$'\n'};
    elif [ "$PREV" = "--ssl" ]; then
        WORDS="ssl2.3 tls1 tls1.1 tls1.2"
    elif [ "$PREV" = "--auth-type" -o "$PREV" = "-A" ]; then
        WORDS="basic bearer digest"
    elif [ "$PREV" = "--print" -o "$PREV" = "-p" ]; then
        WORDS="H B h b m"
    elif [ "$PREV" = "--pretty" ]; then
        WORDS="all colors format none"
    elif [ "$PREV" = "--style" -o "$PREV" = "-s" ]; then
        WORDS="abap algol algol_nu arduino auto autumn borland bw
          colorful default dracula emacs friendly
          friendly_grayscale fruity gruvbox-dark gruvbox-light
          igor inkpot lilypond lovelace manni material monokai
          murphy native one-dark paraiso-dark paraiso-light
          pastie perldoc pie pie-dark pie-light rainbow_dash
          rrt sas solarized solarized-dark solarized-light stata
          stata-dark stata-light tango trac vim vs xcode
          zenburn"
    fi
    COMPREPLY=( $(compgen -W "$WORDS" -- "$CUR") )
    [ "${COMPREPLY: -1}" = "=" ] && compopt -o nospace
}

complete -o default -o bashdefault -F _httpie http https httpie

