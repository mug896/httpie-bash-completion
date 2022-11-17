_init_comp_wordbreaks()
{
    if [[ $PROMPT_COMMAND =~ ^:[^\;]+\;COMP_WORDBREAKS ]]; then
        [[ $PROMPT_COMMAND =~ ^:\ ([^;]+)\; ]]
        [[ ${BASH_REMATCH[1]} != "${COMP_WORDS[0]}" ]] && eval "${PROMPT_COMMAND%%$'\n'*}"
    fi
    if ! [[ $PROMPT_COMMAND =~ ^:[^\;]+\;COMP_WORDBREAKS ]]; then
        PROMPT_COMMAND=": ${COMP_WORDS[0]};COMP_WORDBREAKS=${COMP_WORDBREAKS@Q};\
        "$'PROMPT_COMMAND=${PROMPT_COMMAND#*$\'\\n\'}\n'$PROMPT_COMMAND
    fi
}
_http () 
{
    # It is recommended that all completion functions start with _init_comp_wordbreaks,
    # regardless of whether you change the COMP_WORDBREAKS variable afterward.
    _init_comp_wordbreaks
    [[ $COMP_WORDBREAKS != *"@"* ]] && COMP_WORDBREAKS+="@"
    local cmd=$1 cur=${COMP_WORDS[COMP_CWORD]} prev=${COMP_WORDS[COMP_CWORD-1]}
    [[ ${COMP_LINE:COMP_POINT-1:1} = " " ]] && cur=""
    local IFS=$' \t\n' words _cmd=__$cmd
    local ver=$(stat -L -c %Y `type -P "$cmd"`)
    local help=${!_cmd#*$'\n'}

    [[ $prev == "=" ]] && prev=${COMP_WORDS[COMP_CWORD-2]}
    if [[ $cur == -* ]]; then
        if [[ -z ${!_cmd} || $ver != ${!_cmd%%$'\n'*} ]]; then
            eval ${_cmd}='$ver$'"'\\n'"'$( $cmd --help )'
        fi
        words=$(<<< ${!_cmd#*$'\n'} sed -En '/^  -/p' | grep -Eo -- ' -[[:alnum:]-]+\b')
    elif [[ $prev == --ssl ]]; then
        words=$(<<< $help sed -En '/^[ ]{,5}--ssl/{ s/^[^{]*(.*)}.*/\1/; s/,|\{|}/ /g; p }')
    elif [[ $prev == @(-!(-*)A|--auth-type) ]]; then
        words="basic bearer digest"
    elif [[ $prev == @(-!(-*)p|--print) ]]; then
        IFS=$'\n'
        words='
"H" request headers
"B" request body
"h" response headers
"b" response body
"m" response metadata
'
    elif [[ $prev == --pretty ]]; then
        words="all colors format none"
    elif [[ $prev == @(-!(-*)s|--style) ]]; then
        words="abap algol algol_nu arduino auto autumn borland bw
          colorful default dracula emacs friendly
          friendly_grayscale fruity gruvbox-dark gruvbox-light
          igor inkpot lilypond lovelace manni material monokai
          murphy native one-dark paraiso-dark paraiso-light
          pastie perldoc pie pie-dark pie-light rainbow_dash
          rrt sas solarized solarized-dark solarized-light stata
          stata-dark stata-light tango trac vim vs xcode
          zenburn"
    elif [[ $cur == "@" || $prev == @(-!(-*)o|--output) ]]; then
        :
    else
        local i methods="GET POST PUT HEAD DELETE PATCH OPTIONS CONNECT TRACE"
        for (( i = 1; i < ${#COMP_WORDS[@]}; i++ )); do
            [[ ${COMP_WORDS[i]} == @(${methods// /|}) ]] && break
        done
        (( i == ${#COMP_WORDS[@]} )) && words=$methods
    fi
    [[ $COMP_WORDBREAKS == *$cur* ]] && cur=""
    COMPREPLY=( $(compgen -W '$words' -- "$cur") )
}

_httpie () 
{
    local cur=$2
    local IFS=$' \t\n' words help
    HELP=$( eval "${COMP_LINE% *} --help" 2>&1 ) || return;

    if [[ $cur == -* ]]; then
        words=$( <<< $help \
            sed -En '/^options:/,/\a/{ //d; /^  -/p; }' | grep -Eo -- ' -[[:alnum:]-]+\b' )
    else
        words=$( <<< $help \
            sed -En '/^positional arguments:/,/^options:/{ //d; s/^[^{]*(.*)}.*/\1/; s/,|\{|}/ /g; p }' )
    fi
    COMPREPLY=( $(compgen -W "$words" -- "$cur") )
}

complete -o default -o bashdefault -F _http http https
complete -o default -o bashdefault -F _httpie httpie

