#!/bin/bash

## hack
## A simple script to automate a Git workflow

## Credits
#  Variation on ReinH's script for managing the git process
#  as documented here: http://reinh.com/blog/2008/08/27/hack-and-and-ship.html

## Configuration
#  Set your preferred default branch to hack in
DEFAULT_BRANCH="development"

## For basic usage you should not need to edit anything below this line #######
usage() {
	echo " "
	echo "Usage: hack {on, sync, push}"
	echo " "
	echo "hack on <branch>"
	echo "If no branch is supplied '$DEFAULT_BRANCH' is used."
	echo " "
	echo "hack sync"
	echo "Rebase to master branch"
	echo " "
	echo "hack push"
	echo "Merges and pushes to origin master"
	echo " "
	echo "hack ssp (simple software process)"
	echo "hack sync && hack push"
	echo "Use -t flag (hack ssp -t) to include rake testing"
	
	exit 1
}

set_current_branch() {
	if [ ! $CURRENT ]; then CURRENT=`git branch | grep "*" | awk '{print $2}'`; fi
	
}

set_target_branch() {
	if [ $1 ]; then 
		BRANCH=$1
	else
		BRANCH=$DEFAULT_BRANCH
	fi
}

create_branch_unless_exists() {
	# sed command removes * if present and any leading or trailing white space
	if [ $BRANCH == "`git branch | grep -w "$BRANCH" | sed 's/*//;s/^[ \t]*//;s/[ \t]*$//'`" ]; then 
		echo "Branch $BRANCH already exists.  Switching to existing branch."
	else 
	  git branch $BRANCH
		echo "New branch $BRANCH created."
 fi
}

hack_on() {
	set_current_branch
	set_target_branch $1	
	if [ $CURRENT != "master" ]; then git checkout master; fi
	git pull origin master
	create_branch_unless_exists
	git checkout $BRANCH
}

hack_sync() {
	set_current_branch
	git checkout master
	git pull origin master
	git checkout ${CURRENT}
	git rebase master
}

hack_push() {
	set_current_branch
	git checkout master
	git merge ${CURRENT}
	git push origin master
	git checkout ${CURRENT}
}

case $1 in
  on*)
		hack_on $2
		;;
	sync*)
		hack_sync
		;;
	push*)
		hack_push
		;;
	ssp*)
		if [ "$2" = "-t" ]; then
			hack_sync && rake && hack_push
		else
		  hack_sync && hack_push
		fi
		;;
	*)
		echo 2>&1 "Unrecognized command: $1"
		usage
		;;
esac