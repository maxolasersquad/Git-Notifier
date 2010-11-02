#!/bin/bash
#   This file is part of Git-Notifier.
#
#   Git-Notifier is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License.
#
#   Git-Notifier is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with Git-Notifier.  If not, see <http://www.gnu.org/licenses/>.

#Check that we have a ~/.gitnotify directory.  Make it if we don't
if [[ ! -d ~/.gitnotify ]]; then
  mkdir ~/.gitnotify
fi

#Initialize gitnotify
GN_INI_FILE=~/.gitnotify/gitnotify.ini
GN_REPOS=`cat $GN_INI_FILE | grep ^repos= | sed -u 's/repos=//g'`
GN_DURATION=`cat $GN_INI_FILE | grep ^duration= | sed -u 's/duration=//g'`
GN_PRETTY=`cat $GN_INI_FILE | grep ^pretty= | sed -u 's/pretty=//g'`

declare -A GN_LASTSHOW

#Initialize LASTSHOW array
for GN_REPO in $GN_REPOS; do
  if [[ -d ~/.gitnotify/$GN_REPO ]] ; then
    cd ~/.gitnotify/$GN_REPO
    for GN_BRANCH in `git branch -a | grep / | sed 's/ -> .*//'`; do
      GN_LASTSHOW[${GN_REPO}_${GN_BRANCH}]=`git show $GN_BRANCH --pretty=$GN_PRETTY`
    done
  else
    echo Unable to locate ~/.gitnotify/$GN_REPO repository >> ~/.gitnotify/log
  fi
done

git fetch

#Check for updates and notify when necessary
while true; do
  for GN_REPO in $GN_REPOS; do
    if [[ -d ~/.gitnotify/$GN_REPO ]]; then
      cd ~/.gitnotify/$GN_REPO
      #Loop through all of the local branches in the repository
      for GN_BRANCH in `git branch -a | grep / | sed 's/ -> .*//'`; do
        GN_GITSHOW=`git show $GN_BRANCH --pretty=$GN_PRETTY`
        if [ "${GN_LASTSHOW[$GN_REPO_$GN_BRANCH]}" != "$GN_GITSHOW" ]; then
          notify-send -i gtk-dialog-info -t 300000 -- "Git Update - $GN_REPO" "$GN_GITSHOW"
        fi
        GN_LASTSHOW[$GN_REPO_$GN_BRANCH]=$GN_GITSHOW
      done
    else
      echo Unable to locate ~/.gitnotify/$GN_REPO repository.  Please update ~/.gitnotify/gitnotify.ini >> ~/.gitnotify/log
      #Only keep the last thirty logs
      tail -n 30 ~/.gitnotify/log > ~/.gitnotify/log
    fi
  done
  sleep $GN_DURATION
done
