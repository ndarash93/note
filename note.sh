#!/usr/bin/env bash

fatal() {
  echo "[FATAL] $@
  exit 1
}

cleanup(){
  true
}

print_help() {
  echo "-h: Print this menu"
  echo "-l: List all notes in the notes diretory"
  echo "-f: Provide file name for note"
  echo "-d: Debug Mode"
  exit 1
}


set_notes_dir() {
  if [ $# -eq 0 ]; then
    NOTES_DIR="$HOME/Documents/notes"
  else
    NOTES_DIR="$1"
  fi
  mkdir -p "$NOTES_DIR"
}

set_file() {
  if [ $# -eq 0 ]; then
    file="generic.note"
  elif [[ $1 == "*.note" ]]; then
    file="$1"
  else
    file="$1.note"
  fi
}

list_notes() {
  if [[ ! -d "$NOTES_DIR" ]] || [[ -z "$(ls -A "$NOTES_DIR")" ]]; then
    echo "No Notes"
  fi

  for file in "$NOTES_DIR"/*; do
    echo ">>> "$(basename "$file")" <<<"
    for line in "$(cat "$file")"; do
      echo "$line" | nl
    done
  done
}

set_debug_mode() {
  echo "In debug mode"
  echo "All notes will be saved in /tmp/notes"
  DEBUG=1
  set_notes_dir "/tmp/notes"
}

delete_note() {
  local file=$1
  local line=$2

  if [[ $1 == "*.note" ]]; then
    echo "File $file"
  else
    local file="$1.note"
    echo "File $file"
  fi

  if [[ ! -f "$NOTES_DIR/$file" ]]; then
    echo "File "$file" not found"
    return 1
  fi

  if [[ -z "$line" || ! "$line" =~ ^[0-9]+$ ]]; then
    echo "Invalid line number $line"
    return 1
  fi

  sed -i "${line}d" "NOTES_DIR/$file"
  echo "Item $line in $file deleted"
}

# Parse flags
while getopts "hf:ld" opt; do
  case $opt in
    h) print_help ;;
    f) set_file $OPTARG ;;
    l) list_notes ;;
    d) set_debug_mode ;;
    *) print_help ;;
  esac
done

if [ $# -eq 0 ]; then
  print_help
  exit 1
fi

shift $((OPTIND-1))

cmd="$1"
case "$cmd" in
  delete) delete_note $2 $3
esac

if [ -z $file ]; then
  set_file $1
fi

if [ -z $NOTES_DIR ]; then
  set_notes_dir
fi

if [ $# -ne 0 ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') — $*" >> "$NOTES_DIR/$file"
fi

