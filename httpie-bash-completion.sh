_http () 
{
    local CMD=${COMP_WORDS[0]}
    local CUR=${COMP_WORDS[COMP_CWORD]}
    local PREV=${COMP_WORDS[COMP_CWORD-1]}
    local IFS=$' \t\n' WORDS _CMD=__$CMD
    local VER=$(stat -L -c %Y `type -P "$CMD"`)
    local HELP=${!_CMD#*$'\n'}

    [ "$PREV" = "=" ] && PREV=${COMP_WORDS[COMP_CWORD-2]}
    if [ "${CUR:0:1}" = "-" ]; then
        if [ -z "${!_CMD}" -o "$VER" != "${!_CMD%%$'\n'*}" ]; then
            eval ${_CMD}='$VER$'\''\n'\''$( $CMD --help )'
        fi
        WORDS=$(echo "${!_CMD#*$'\n'}" | sed -En '/^  -/p' | grep -Eo -- ' -[[:alnum:]-]+\b')
    elif [ "$PREV" = "--ssl" ]; then
        WORDS=$(echo "$HELP" | sed -En '/^  --ssl/{ s/^[^{]*(.*)[^}]*$/\1/; s/,|\{|}/ /g; p }')
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
    elif [[ "${CUR:0:1}" != @(\'|\"|=) ]]; then
        WORDS="GET POST PUT HEAD DELETE PATCH OPTIONS CONNECT TRACE"
    fi
    [ "$CUR" = "=" ] && CUR=""
    COMPREPLY=( $(compgen -W "$WORDS" -- "$CUR") )
}

_httpie () 
{
    local CUR=${COMP_WORDS[COMP_CWORD]}
    local IFS=$' \t\n' WORDS HELP
    HELP=$( eval "${COMP_LINE% *} --help" 2>&1 ) || return;

    if [ "${CUR:0:1}" = "-" ]; then
        WORDS=$( echo "$HELP" | 
            sed -En '/^options:/,/^END/{ //d; /^  -/p; }' | grep -Eo -- ' -[[:alnum:]-]+\b' )
    else
        WORDS=$( echo "$HELP" | 
            sed -En '/^positional arguments:/,/^options:/{ //d; s/^[^{]*(.*)[^}]*$/\1/; s/,|\{|}/ /g; p }' )
    fi
    COMPREPLY=( $(compgen -W "$WORDS" -- "$CUR") )
}

complete -o default -o bashdefault -F _http http https
complete -o default -o bashdefault -F _httpie httpie

