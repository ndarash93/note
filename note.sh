#!/usr/bin/env bash


# Constants
RED=$'\033[0;31m'
IMPORTANT=0

# Colors
Black=$'\033[0;30m'
Dark_Gray=$'\033[1;30m'
Red=$'\033[0;31m'
Light_Red=$'\033[1;31m'
Green=$'\033[0;32m'
Light_Green=$'\033[1;32m'
Orange=$'\033[0;33m'
Yellow=$'\033[1;33m'
Blue=$'\033[0;34m'
Light_Blue=$'\033[1;34m'
Purple=$'\033[0;35m'
Light_Purple=$'\033[1;35m'
Cyan=$'\033[0;36m'
Light_Cyan=$'\033[1;36m'
Light_Gray=$'\033[0;37m'
White=$'\033[1;37m'
No_Color=$'\033[0m'

fatal() {
  echo "[FATAL] $@"
  exit 1
}

cleanup(){
  true
}

init() {
  TEXT_COLOR='\033[0m'
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
  
  local line_num=1

  for file in "$NOTES_DIR"/*; do
    echo "=== $(basename "$file") ==="
    while IFS= read -r line; do
      if [[ $IMPORTANT -eq 1 && $line == *"$RED"* ]]; then
        echo -e "\t$line_num\t$line"
      elif [[ $IMPORTANT -ne 1 ]]; then
        echo -e "\t$line_num\t$line"
      fi
      ((line_num++))
    done < $file
  done
  exit 1
}

set_debug_mode() {
  echo "In debug mode"
  echo "All notes will be saved in /tmp/notes"
  DEBUG=1
  set_notes_dir "/tmp/notes"
}

set_important() {
  TEXT_COLOR=$RED
}

set_color() {
  case $1 in 
    black) TEXT_COLOR=$Black ;;
    red) TEXT_COLOR=$Red ;;
    yellow) TEXT_COLOR=$Yellow ;;
    green) TEXT_COLOR=$Green ;;
    blue) TEXT_COLOR=$Blue ;;
    cyan) TEXT_COLOR=$Cyan ;;
    orange) TEXT_COLOR=$Orange ;;
    *) TEXT_COLOR=$No_Color ;;
  esac
}

remove_note() {
  if [[ $1 =~ ^.*\.note$ ]]; then
    local file=$1
  else
    local file="$1.note"
  fi

  if [[ $2 =~ ^[0-9]+$ ]]; then 
    local line=$2
  else 
    fatal "Invalid note number"
  fi

  if [[ ! -f "$NOTES_DIR/$file" ]]; then
    fatal "File $NOTES_DIR/$file not found"
  fi

  local line_count=$(wc -l < $NOTES_DIR/$file)
  if [[ -z "$line" || ! "$line" =~ ^[0-9]+$ || $line -gt $line_count ]]; then
    fatal Invalid line number $line
  fi


  sed -i '' "${line}d" $NOTES_DIR/$file
  echo "Item $line in $NOTES_DIR/$file deleted"
  exit 1
}

init
set_notes_dir

# Parse flags
while getopts "hf:ldir:c:" opt; do
  case $opt in
    h) print_help ;;
    f) set_file $OPTARG ;;
    l) DO_LIST=1 ;;
    d) DEBUG=1 ;;
    i) IMPORTANT=1 ;;
    r) 
      file=$OPTARG
      note_num=${!OPTIND}
      ((OPTIND++))
      REMOVE=1
      ;;
    c) set_color $OPTARG ;;
    #*) print_help ;;
  esac
done

if [ $# -eq 0 ]; then
  print_help
  exit 1
fi

if [[ -n $DUBUG && $DEBUG -eq 1 ]]; then
  set_debug_mode
fi

if [[ ! -z $DO_LIST && $DO_LIST -eq 1 ]]; then
  list_notes
fi

if [[ ! -z $IMPORTANT && $IMPORTANT -eq 1 ]]; then
  set_important
fi

if [[ ! -z $REMOVE && $REMOVE -eq 1 ]]; then
  remove_note $file $note_num
fi


shift $((OPTIND-1))

cmd="$1"
case "$cmd" in
  --delete) echo "TEST" #delete_note $2 $3
esac

if [ -z $file ]; then
  set_file
fi

if [ -z $NOTES_DIR ]; then
  set_notes_dir
fi

#### MAIN
if [ $# -ne 0 ]; then
  echo -e "$TEXT_COLOR$(date '+%Y-%m-%d %H:%M:%S') — $*$No_Color" >> "$NOTES_DIR/$file"
fi

