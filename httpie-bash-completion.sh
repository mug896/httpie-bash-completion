_http () 
{
    local CMD=${COMP_WORDS[0]}
    local CUR=${COMP_WORDS[COMP_CWORD]}
    local PREV=${COMP_WORDS[COMP_CWORD-1]}
    local IFS=$' \t\n' WORDS TMP _CMD=__$CMD
    local VER=$(stat -c %Y `type -P "$CMD"`)

    if [ "${CUR:0:1}" = "-" ]; then
        if [ -z "${!_CMD}" -o "$VER" != "${!_CMD%%$'\n'*}" ]; then
            TMP=$VER$'\n'$( $CMD --help | sed -En '/^  -/p' | grep -Eo -- ' -[[:alnum:]-]+' )
            eval ${_CMD}='$TMP'
        fi
        WORDS=${!_CMD#*$'\n'};
    elif [ "$PREV" = "--ssl" ]; then
        WORDS="ssl2.3 tls1 tls1.1 tls1.2"
    elif [ "$PREV" = "--auth-type" -o "$PREV" = "-A" ]; then
        WORDS="basic bearer digest"
    elif [ "$PREV" = "--print" -o "$PREV" = "-p" ]; then
        IFS=$'\n'
        WORDS='\"H\" request headers
\"B\" request body
\"h\" response headers
\"b\" response body
\"m\" response metadata'
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
    elif [[ ! "${CUR:0:1}" =~ \'|\" ]]; then
        WORDS="GET POST PUT HEAD DELETE PATCH OPTIONS CONNECT TRACE"
    fi
    COMPREPLY=( $(compgen -W "$WORDS" -- "$CUR") )
    [ "${COMPREPLY: -1}" = "=" ] && compopt -o nospace
}

_httpie () 
{
    local CUR=${COMP_WORDS[COMP_CWORD]}
    local IFS=$' \t\n' WORDS
    local HELP=$( eval "${COMP_LINE% *} --help" 2>&1 ) || return;

    if [ "${CUR:0:1}" = "-" ]; then
        WORDS=$( echo "$HELP" | 
            sed -En '/^options:/,/^END/{ //d; /^  -/p; }' | grep -Eo -- ' -[[:alnum:]-]+' )
    else
        WORDS=$( echo "$HELP" | 
            sed -En '/^positional arguments:/,/^options:/{ //d; s/^[^{]*(.*)[^}]*$/\1/; s/,|\{|}/ /g; p }' )
    fi

    COMPREPLY=( $(compgen -W "$WORDS" -- "$CUR") )
    [ "${COMPREPLY: -1}" = "=" ] && compopt -o nospace
}

complete -o default -o bashdefault -F _http http https
complete -o default -o bashdefault -F _httpie httpie

