# Workarounds

The generated option parser code contains workarounds for several shell bugs.
The reason why those codes are needed is not easy to understand and is explained here.
If you do not need these workarounds, you can remove them manually.

```sh
# e.g.
eval 'set -- "${OPTARG%%\=*}" "${OPTARG#*\=}"' ${1+'"$@"'}
eval '[ ${OPTARG+x} ] &&:' && OPTARG=1 || OPTARG=-1
$1*) OPTARG="$OPTARG --flag"
VERBOSE="$((${VERBOSE:-0}+$OPTARG))"
```

## 1. `${1+'"$@"'}`

```sh
eval 'set -- "${OPTARG%%\=*}" "${OPTARG#*\=}"' ${1+'"$@"'}

# Equivalent to the following
set -- "${OPTARG%%\=*}" "${OPTARG#*\=}" "$@"
```

This is a well-known workaround the problem of using `set -u` for some shells.
See [What does `${1+"$@"}` mean](https://www.in-ulm.de/~mascheck/various/bourne_args/).

> Oh wait, there's another meaning
> It's also a workaround for a problem in some shells if you want to use the flag u ("error upon using empty variables")
> and `"$@" `(or `$@`, `"$*"`, `$*`) is used without arguments. Example:
>
> ```sh
> $ shell -cu 'echo     "$@";  echo not reached'
> @: parameter not set
> $ shell -cu 'echo ${1+"$@"}; echo ok'
> ok
> ```
>
> At least these shells need that workaround:
>
> - bash-4.0.0 ... -4.0.27
> - dash-0.4.6 ... -0.4.18
> - all ksh88
> - ksh93 until release t+20090501
> - pdksh-5.1.3, -5.2.14
> - mksh before R39 (as pdksh descendant)
> - posh < 0.10 (as pdksh descendant)
> - NetBSD 2 ff. /bin/sh
> - all traditional Bourne shells

NOTE: In **NetBSD ksh on NetBSD 9.0** and **posh 0.14.1**, this problem still exists.

### `${1+"$@"}` vs `${1+'"$@"'}`

However, this workaround does not work properly with old zsh 3.x, so we are using a modified version.

```console
$ echo $ZSH_VERSION
3.1.9
$ set -- a b c; printf '[%s] ' ${1+"$@"}; echo
[a b c]
# correct: [a] [b] [c]
```

Modified version

```sh
eval 'set -- "${OPTARG%%\=*}" "${OPTARG#*\=}"' ${1+'"$@"'}

# if $1 is present, then
=> eval 'set -- "${OPTARG%%\=*}" "${OPTARG#*\=}"' '"$@"'
=> set -- "${OPTARG%%\=*}" "${OPTARG#*\=}" "$@"

# if $1 is not present, then
=> eval 'set -- "${OPTARG%%\=*}" "${OPTARG#*\=}"'
=> set -- "${OPTARG%%\=*}" "${OPTARG#*\=}"
```

## 2. `eval '[ ${OPTARG+x} ]'`

```sh
eval '[ ${OPTARG+x} ]' && OPTARG=1 || OPTARG=-1
```

This is a workaround for ksh 93u+. The code without the workaround is the following.

```sh
[ ${OPTARG+x} ] && OPTARG=1 || OPTARG=-1
```

The reproduction code is as follows. The `eval` avoids this problem.

```sh
#!/usr/bin/ksh
set -eu 1 2
VAR='var'
while [ $# -gt 0 ]; do
  [ $# -eq 1 ] && unset VAR  # unset VAR in the last loop
  if [ "${VAR+x}" ]; then    # if variable VAR is set

    # The last loop will be executed even though the variable VAR is not set
    echo "$VAR" # => [error] VAR: parameter not set

  fi
  shift
done
```

## 3. `eval '[ ... ] &&:'`

```sh
eval '[ ${OPTARG+x} ] &&:' && OPTARG=1 || OPTARG=-1
```

This `&&:` is a workaround for OpenBSD ksh.

The reproduction code is as follows.

```sh
set -eu
eval "[ ]"     && v=1 || v=2 # it should not exit with failure, but it does
eval "[ ] &&:" && v=1 || v=2 # it works as expected
```

## 4. `$1*)`

The `$1` in this code should be enclosed in double quotes. If `$1` contains a pattern string, it will cause incorrect behavior.

```sh
set -- "???"
case foo in
  "$1"*) echo "it doesn't match" ;; # correct
  $1*) echo "it matches" ;; # wrong
esac
```

However, posh 0.10.2, 0.12.6 doesn't work properly when variables are
enclosed in double quotes.

```sh
#!/usr/bin/posh
set -- "foo"
case foo in
  "$1"*) echo "ok" ;;
  *) echo "not ok" >&2; exit 1 ;; # posh 0.10.2, 0.12.6
esac
```

Therefore, it cannot be enclosed in double quotes, but it would be in trouble
if `$1` contains a pattern, so we check it beforehand.

```sh
case $1 in (*[!a-zA-Z0-9_-]*) break; esac
```

This workaround has a very limited number of affected shells and limits the characters that can be used as long options, so it may be removed in the future.

## 5. `$((${VERBOSE:-0}+$OPTARG))`

There is no need to use `$` to refer to simple variables in arithmetic expressions.

```sh
VERBOSE="$((${VERBOSE:-0}+OPTARG))"
```

However, older shells (e.g. dash 0.5.2) require `$`. The affected shells are
limited and quite old, but we use `$` because it doesn't cause any problems.
