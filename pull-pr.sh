#!/usr/bin/env bash

pr_path=$1
repo=$2

[ -z "$pr_path" ] || [ -z "$repo" ] && exit 1

IFS=':' read -a parts <<< "$pr_path"

pr_path="${pr_path/:/-}"

git checkout -b "$pr_path" && git pull "git@github.com:${parts[0]}/$repo" "${parts[1]}"
