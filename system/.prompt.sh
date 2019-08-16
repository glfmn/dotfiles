#!/bin/bash

export GIT_FMT="\[#g;*(\b)#r(\B(#~(' ⇒ ')))#w(\(#~;*(\+('↑')\-('↓')))\<#g(\M\A\R\D)#r(\m\a\u\d)>\{#m;*;_(\h('@'))})]' '#b;*('\w')'\n '"

export PS1_FMT="#g;*('\h')' '#b;*('\w')'\n '"

__set_prompt() {
  local EXIT="$?"
  # Capture last command exit flag first

  PS1=""
  # If the last command didn't exit 0, display the exit code
  [ "$EXIT" -ne "0" ] && PS1+="$EXIT "

  PS1+="$(glit "$GIT_FMT" -e "$PS1_FMT")"
}
export PROMPT_COMMAND=__set_prompt
