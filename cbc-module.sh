#!/usr/bin/env bash

################################################################################
# REPEAT
################################################################################

repeat() {
  OPTIND=1        # Reset getopts index to handle multiple runs
  local delay=0   # Default delay is 0 seconds
  local verbose=0 # Default verbose mode is off
  local count     # Declare count as a local variable to limit its scope

  # Function to display help
  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Repeats any given command a specified number of times."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  repeat [-h] count [-d delay] [-v] command [arguments...]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h            Display this help message and return" \
      "  -d delay      Delay in seconds between each repetition" \
      "  -v            Enable verbose mode for debugging and tracking runs"

    cbc_style_box "$CATPPUCCIN_LAVENDER" "Arguments:" \
      "  count         The number of times to repeat the command" \
      "  command       The command(s) to be executed (use ';' to separate multiple commands)" \
      "  [arguments]   Optional arguments passed to the command(s)"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  repeat 3 echo \"Hello, World!\"" \
      "  repeat 5 -d 2 -v echo \"Hello, World!\""
  }

  # Parse options first
  while getopts "hd:v" opt; do
    case "$opt" in
    h)
      usage
      return 0
      ;;
    d)
      delay="$OPTARG"
      if ! echo "$delay" | grep -Eq '^[0-9]+$'; then
        cbc_style_message "$CATPPUCCIN_RED" "Error: DELAY must be a non-negative integer."
        return 1
      fi
      ;;
    v)
      verbose=1
      ;;
    *)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      usage
      return 1
      ;;
    esac
  done
  shift $((OPTIND - 1)) # Remove parsed options from arguments

  # Check if help flag was invoked alone
  if [ "$OPTIND" -eq 2 ] && [ "$#" -eq 0 ]; then
    return 0
  fi

  # Ensure count argument exists
  if [ "$#" -lt 2 ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: Missing count and command arguments."
    usage
    return 1
  fi

  count=$1 # Assign count within local scope
  shift

  # Ensure count is a valid positive integer
  if ! echo "$count" | grep -Eq '^[0-9]+$'; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: COUNT must be a positive integer."
    usage
    return 1
  fi

  # Ensure a command is provided
  if [ "$#" -lt 1 ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: No command provided."
    usage
    return 1
  fi

  # Combine remaining arguments as a single command string
  local cmd="$*"

  # Repeat the command COUNT times with optional delay
  for i in $(seq 1 "$count"); do
    if [ "$verbose" -eq 1 ]; then
      cbc_style_message "$CATPPUCCIN_SKY" "Running iteration $i of $count: $cmd"
    fi
    eval "$cmd"
    if [ "$delay" -gt 0 ] && [ "$i" -lt "$count" ]; then
      if [ "$verbose" -eq 1 ]; then
        cbc_style_message "$CATPPUCCIN_SUBTEXT" "Sleeping for $delay seconds..."
      fi
      sleep "$delay"
    fi
  done
}
