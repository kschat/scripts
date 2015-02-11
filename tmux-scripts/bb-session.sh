#!/usr/bin/env bash

path="${@: -1}"
session=""
repo=""
user=""
node_arguments=""
verbose=""

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      setup-bb-repo.sh -h
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
    -n|--node-args)
      shift
      node_arguments="$1"
      shift
      ;;
    -v|--verbose)
      verbose="$1"
      shift
      ;;
    *)
      break
      ;;
  esac
done

session=${session:-$repo}
repo="$repo"

#create new tmux session, but don't attach to it
tmux -2 new -d -s "$session"

# create window for frontend and split it horizontally
tmux new-window -t "$session:0" -n Frontend
tmux split-window -h

# create window for API and split it horizontally
tmux new-window -t "$session:1" -n API
tmux split-window -h

# select the API window and run `setup-bb-repo.sh` in the second pane
tmux select-window -t 1
tmux send-keys -t 1 "setup-bb-repo.sh $verbose -u $user -r $repo.api -n \"$node_arguments\" $path" C-m
tmux send-keys -t 0 "cd $path/$repo.api"
tmux select-pane -L

# select the Frontend window and run `setup-bb-repo.sh` in the second pane
tmux select-window -t 0
tmux send-keys -t 1 "setup-bb-repo.sh $verbose -u $user -r $repo.m -n \"--url http://localhost:4000 $node_arguments\" $path" C-m
tmux send-keys -t 0 "cd $path/$repo.m"
tmux select-pane -L

tmux -2 attach-session -t $session