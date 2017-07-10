#!/bin/bash

__is_git_repo() {
  # return 128 if not in git repository, return 0 if in repo
  git status -sb --porcelain &>/dev/null
  echo "$?"
}

__formatter() {
  local count="$(git status --porcelain | grep -ce "$4")"
  local formatted="$5"
  [ "$count" -lt "1" ] && count=""
  formatted="${formatted//\%$1/$count}"
  formatted="${formatted//\%$2/$([ -z $count ] || echo $3$count)}"
  echo "$formatted"
}

__git_stats() { # (format)
  # Check if stats is in a git repository
  [ "$(__is_git_repo)" -ne 0 ] && echo "not a git repository" && return 128

  # Echo usage if no argument specified
  [ -z "$1" ] && echo -e "\033[1;37musage: __git_stats [format]\033[0m
  format parameters:
  \t%b\tbranch name
  \t%a\tnumber of added files
  \t%A\tnumber of added files with an A in front
  \t%d\tnumber of deleted files
  \t%D\tnumber of deleted files with a D in front
  \t%m\tnumber of modified files, or number of files with unstaged changes
  \t%M\tnumber of modified files with an M in front
  \t%r\tnumber of renamed files
  \t%R\tnumber of renamed files with an R in front
  \t%s\tnumber of staged files with changes
  \t%S\tnumber of staged files with an M in front
  \t%u\tnumber of untracked files
  \t%U\tnumber of untracked files with a ? in front
  \t%x\tnumber of confilcts on a merge
  \t%X\tnumber of confilcts on a merge with a UU in front
  \t%+\tnumber of commits ahead of tracking branch with + as prefix
  \t%-\tnumber of commits behind tracking branch with - as prefix

  \texample: __git_stats \"(%b%+%-)[%u%m%d%R]\"
  \t__git_stats will clear out any empty braces, specifically <>,
  \t\t(), [], and {}" && return 2

  local format="$1"
  local st="$(git status --porcelain)"
  local branch="$(git symbolic-ref --short HEAD)"
  local upstream="$(git for-each-ref --format='%(upstream:short)' $(git symbolic-ref -q HEAD))"

  # Get the current branch and replace branch format specifier
  format="${format//\%b/$branch}"

  format="$(__formatter "m" "M" "M" "^.M" $format)"
  format="$(__formatter "s" "S" "M" "^M" $format)"
  format="$(__formatter "a" "A" "A" "^A" $format)"
  format="$(__formatter "r" "R" "R" "^R" $format)"
  format="$(__formatter "u" "U" "?" "^?" $format)"
  format="$(__formatter "d" "D" "D" "^D" $format)"
  format="$(__formatter "x" "X" "UU" "^UU" $format)"

  if git rev-parse --abbrev-ref --symbolic-full-name @{u} &>/dev/null; then
    local ahead="$(git rev-list --left-right $upstream..$branch | grep -c '>')"
    [ "$ahead" -gt "0" ] && format="${format//\%+/+$ahead}"

    local behind="$(git rev-list --left-right $branch..$upstream | grep -c '>')"
    [ "$behind" -gt "0" ] && format="${format//\%-/-$behind}"
  fi
  format="${format//\%+/}"
  format="${format//\%-/}"

  # Clear out empty braces if substitutions have resulted in empty braces
  format="${format//()/}"
  format="${format//<>/}"
  format="${format//[]/}"
  format="${format//\{\}/}"

  echo "$format"
}

__set_prompt() {
  local EXIT="$?"
  # Capture last command exit flag first

  # If color support exists, set color values, otherwise set them as empty
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    local nc="\[\033[0m\]"
    local red="\[\033[00;31m\]"
    local grn="\[\033[00;32m\]"
    local ylw="\[\033[00;33m\]"
    local blu="\[\033[00;34m\]"
    local bgrn="\[\033[01;32m\]"
    local bylw="\[\033[01;33m\]"
    local bblu="\[\033[01;34m\]"
    local bpur="\[\033[01;35m\]"
  fi

  # Clear out prompt
  PS1=""

  # If the last command didn't exit 0, display the exit code
  [ "$EXIT" -ne "0" ] && PS1+="$red$EXIT$nc "

  # identify debian chroot, if one exists
  if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    PS1+="${debian_chroot:+($(cat /etc/debian_chroot))}"
  fi

  if [ "$(__is_git_repo)" -eq "0" ]; then
    local stats="$(__git_stats "($bpur%b$grn%+$red%-$nc)$grn%A%R%S$red%M%D%U%X$nc")"
    PS1+="$stats:$bylw\w$nc\n\$ "
  else
    PS1+="$bgrn\u$grn@\h$nc:$bblu\w$nc\$ "
  fi
}
export PROMPT_COMMAND=__set_prompt
