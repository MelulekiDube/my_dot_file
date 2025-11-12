# ----- Right prompt: duration + time -----

setopt PROMPT_SUBST

# Track start and end time for each command
integer __CMD_START=0 __CMD_ELAPSED=0

preexec() {
  __CMD_START=$EPOCHSECONDS
}

precmd() {
  if (( __CMD_START > 0 )); then
    __CMD_ELAPSED=$(( EPOCHSECONDS - __CMD_START ))
    __CMD_START=0
  fi

  # Format duration (only show if >0s)
  local dur=""
  (( __CMD_ELAPSED > 0 )) && dur="⏱ ${__CMD_ELAPSED}s "

  # Display right-side prompt
  local time="$(date +%H:%M:%S)"
  RPROMPT="${dur}🕒 $time"
}
