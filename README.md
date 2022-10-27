## Httpie Bash Completion

Copy contents of `httpie-bash-completion.sh` file to `~/.bash_completion`.  
open new terminal and try auto completion !

> please leave an issue above if you have any problems using this script.

```sh
bash$ http --version 
3.2.1

bash$ http -[tab]
--all                --format-options     --raw                -S
--auth               --headers            --response-charset   -a
--auth-type          --help               --response-mime      -b
--body               --ignore-netrc       --session            -c
--boundary           --ignore-stdin       --session-read-only  -d
--cert               --json               --sorted             -f
--cert-key           --manual             --ssl                -h
--cert-key-pass      --max-headers        --stream             -j
--check-status       --max-redirects      --style              -m
--chunked            --meta               --timeout            -o
--ciphers            --multipart          --traceback          -p
--compress           --offline            --unsorted           -q
--continue           --output             --verbose            -s
--debug              --path-as-is         --verify             -v
--default-scheme     --pretty             --version            -x
--download           --print              -A
--follow             --proxy              -F
--form               --quiet              -I
```

