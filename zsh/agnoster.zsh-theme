# Minimal agnoster-style prompt: status | dir | git   (RPROMPT is set elsewhere)

prompt_segment() {
  local bg fg text
  bg=$1; fg=$2; text=$3
  [[ -n $bg ]] && print -n "%{$bg%}"
  [[ -n $fg ]] && print -n "%{$fg%}"
  print -n " $text "
  print -n "%{%f%k%}"
}

prompt_status() {
  local ret=$?
  (( ret != 0 )) && prompt_segment "%K{160}" "%F{255}" "✘ $ret"
}

prompt_dir() {
  prompt_segment "%K{240}" "%F{255}" "%~"
}

prompt_git() {
  command -v git >/dev/null 2>&1 || return
  local ref dirty branch
  ref=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null) || return
  git diff --quiet --ignore-submodules HEAD >/dev/null 2>&1
  dirty=$([[ $? -eq 0 ]] && echo '' || echo '*')
  branch=" ${ref}${dirty}"
  prompt_segment "%K{237}" "%F{39}" "$branch"
}

build_prompt() {
  RETVAL=$?
  print -n "%{%f%k%}"
  prompt_status
  prompt_dir
  prompt_git
  print -n "%{%f%k%}%{$reset_color%}\n$ "
}

PROMPT='$(build_prompt)'
