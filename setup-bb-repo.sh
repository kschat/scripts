#!/usr/bin/env bash

path="${@: -1}"
session=""
repo=""
user=""
node_arguments=""
input_error_message=""
repo_exists=false
logging_on=false

# color codes
info_color=$(tput setaf 6)
error_color=$(tput setaf 1)
reset_color=$(tput sgr0)

function log {
  $logging_on && echo "${1}${2}${reset_color}"
}

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo usage: bb-session.sh [-u user] [-r repo] [-s session] [-n node_arguments] path
      exit 0
      ;;
    -u|--user)
      shift
      user="$1"
      shift
      ;;
    -r|--repo)
      shift
      repo="$1"
      shift
      ;;
    -s|--session)
      shift
      session="$1"
      shift
      ;;
    -n|--node)
      shift
      node_arguments="$1"
      shift
      ;;
    -v|--verbose)
      logging_on=true
      shift
      ;;
    *)
      break
      ;;
  esac
done

session="${session:-$repo}"

[ -z "$user" ] && input_error_message+='Must provide a username '

[ -z "$path" ] && input_error_message+='Must provide a path'

if [ -n "$input_error_message" ]; then
  printf '%s%s\n' "$error_color" "$input_error_message"
  exit 1
fi

log $info_color "Checking if repo is already cloned"

# check if repo was already cloned
cd "${path}/${repo}" &> /dev/null && repo_exists=true

if [ $repo_exists = false ]; then

  # check that fork for repo exists
  git ls-remote -h "git@github.com:$user/$repo.git" &> /dev/null || {
    printf 'fork of "%s" doesn'"'"'t exist for user "%s"\n' $repo $user
    exit $?
  }

  log $info_color "Switching directories to $path"
  log $info_color "Cloning git@github.com:$user/$repo.git"

  cd "$path" && git clone "git@github.com:$user/$repo.git" || {
    exit 1
  }

  log $info_color "Switching directories to $repo"
  log $info_color "Creating upstream remote"

  cd "$repo" && git remote add upstream "git@github.com:brandingbrand/$repo.git" || {
    exit 1
  }

  log $info_color "Installing node dependencies"

  npm install || {
    exit 1
  }

  log $info_color "Starting node server"
fi

nodemon app.js $node_arguments