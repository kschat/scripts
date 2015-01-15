#!/bin/bash

path="${@: -1}"
session=""
repo=""
user=""
api_url=localhost:4000

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "usage: bb-session.sh [-u user] [-r repo] [-s session] [path]"
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
    *)
      break
      ;;
  esac
done

session="${session:-$repo}"

if [ -z "$user" ]; then
  echo "Must provide a username"
  exit 1
fi

if [ -z "$path" ]; then
  echo "Must provide a path"
  exit 1
fi

function createWindow() {
  url=$([ -n "$3" ] && echo "--url $3" || echo "")

  tmux new-window -t "$1" -n 0
  tmux split-window -h
  
  tmux send-keys -t 0 "cd ~/Workspace/BB;\
    git clone git@github.com:$user/$2.git;\
    cd $2;\
    tmux select-window -t $1;\
    tmux send-keys -t 1 \"\
      cd ~/Workspace/BB/$2;\
      git remote add upstream git@github.com:brandingbrand/$2.git;\
      npm install; nodemon app.js $url\
    \" C-m" C-m
}

(git ls-remote -h git@github.com:$user/$repo.m.git && git ls-remote -h git@github.com:$user/$repo.api.git) &> /dev/null || {
  printf 'fork of "%s" doesn'"'"'t exist for user "%s"' $repo $user >&2
  exit $?
}

tmux -2 new -d -s "$session"

createWindow "$session:0" "$repo.m" "$api_url"

createWindow "$session:1" "$repo.api"

tmux -2 attach-session -t $session
