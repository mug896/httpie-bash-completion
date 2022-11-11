_init_comp_wordbreaks()
{
    if [[ $PROMPT_COMMAND == *";COMP_WORDBREAKS="* ]]; then
        [[ $PROMPT_COMMAND =~ ^:\ ([^;]+)\; ]]
        [[ ${BASH_REMATCH[1]} != "${COMP_WORDS[0]}" ]] && eval "${PROMPT_COMMAND%%$'\n'*}"
    fi
    if [[ $PROMPT_COMMAND != *";COMP_WORDBREAKS="* ]]; then
        PROMPT_COMMAND=": ${COMP_WORDS[0]};COMP_WORDBREAKS=${COMP_WORDBREAKS@Q};\
        "$'PROMPT_COMMAND=${PROMPT_COMMAND#*$\'\\n\'}\n'$PROMPT_COMMAND
    fi
}
_http () 
{
    # It is recommended that all completion functions start with _init_comp_wordbreaks,
    # regardless of whether you change the COMP_WORDBREAKS variable afterword.
    _init_comp_wordbreaks
    [[ $COMP_WORDBREAKS != *"@"* ]] && COMP_WORDBREAKS+="@"
    local CMD=$1 CUR=${COMP_WORDS[COMP_CWORD]} PREV=${COMP_WORDS[COMP_CWORD-1]}
    [[ ${COMP_LINE:COMP_POINT-1:1} = " " ]] && CUR=""
    local IFS=$' \t\n' WORDS _CMD=__$CMD
    local VER=$(stat -L -c %Y `type -P "$CMD"`)
    local HELP=${!_CMD#*$'\n'}

    [[ $PREV == "=" ]] && PREV=${COMP_WORDS[COMP_CWORD-2]}
    if [[ $CUR == -* ]]; then
        if [[ -z ${!_CMD} || $VER != ${!_CMD%%$'\n'*} ]]; then
            eval ${_CMD}='$VER$'"'\\n'"'$( $CMD --help )'
        fi
        WORDS=$(<<< ${!_CMD#*$'\n'} sed -En '/^  -/p' | grep -Eo -- ' -[[:alnum:]-]+\b')
    elif [[ $PREV == --ssl ]]; then
        WORDS=$(<<< $HELP sed -En '/^[ ]{,5}--ssl/{ s/^[^{]*(.*)}.*/\1/; s/,|\{|}/ /g; p }')
    elif [[ $PREV == @(-!(-*)A|--auth-type) ]]; then
        WORDS="basic bearer digest"
    elif [[ $PREV == @(-!(-*)p|--print) ]]; then
        IFS=$'\n'
        WORDS='
"H" request headers
"B" request body
"h" response headers
"b" response body
"m" response metadata
'
    elif [[ $PREV == --pretty ]]; then
        WORDS="all colors format none"
    elif [[ $PREV == @(-!(-*)s|--style) ]]; then
        WORDS="abap algol algol_nu arduino auto autumn borland bw
          colorful default dracula emacs friendly
          friendly_grayscale fruity gruvbox-dark gruvbox-light
          igor inkpot lilypond lovelace manni material monokai
          murphy native one-dark paraiso-dark paraiso-light
          pastie perldoc pie pie-dark pie-light rainbow_dash
          rrt sas solarized solarized-dark solarized-light stata
          stata-dark stata-light tango trac vim vs xcode
          zenburn"
    elif [[ $CUR == "@" || $PREV == @(-!(-*)o|--output) ]]; then
        :
    else
        local i methods="GET POST PUT HEAD DELETE PATCH OPTIONS CONNECT TRACE"
        for (( i = 1; i < ${#COMP_WORDS[@]}; i++ )); do
            [[ ${COMP_WORDS[i]} == @(${methods// /|}) ]] && break
        done
        (( i == ${#COMP_WORDS[@]} )) && WORDS=$methods
    fi
    [[ $COMP_WORDBREAKS == *$CUR* ]] && CUR=""
    COMPREPLY=( $(compgen -W '$WORDS' -- "$CUR") )
}

_httpie () 
{
    local CUR=$2
    local IFS=$' \t\n' WORDS HELP
    HELP=$( eval "${COMP_LINE% *} --help" 2>&1 ) || return;

    if [[ $CUR == -* ]]; then
        WORDS=$( <<< $HELP \
            sed -En '/^options:/,/\a/{ //d; /^  -/p; }' | grep -Eo -- ' -[[:alnum:]-]+\b' )
    else
        WORDS=$( <<< $HELP \
            sed -En '/^positional arguments:/,/^options:/{ //d; s/^[^{]*(.*)}.*/\1/; s/,|\{|}/ /g; p }' )
    fi
    COMPREPLY=( $(compgen -W "$WORDS" -- "$CUR") )
}

complete -o default -o bashdefault -F _http http https
complete -o default -o bashdefault -F _httpie httpie

