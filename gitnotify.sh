#!/bin/bash

#Check that we have a ~/.gitnotify directory.  Make it if we don't
if [[ ! -d ~/.gitnotify ]]; then
  mkdir ~/.gitnotify
fi

#Initialize gitnotify
GN_INI_FILE=~/.gitnotify/gitnotify.ini
GN_REPOS=`cat $GN_INI_FILE | grep ^repos= | sed -u 's/repos=//g'`
GN_DURATION=`cat $GN_INI_FILE | grep ^duration= | sed -u 's/duration=//g'`
GN_PRETTY=`cat $GN_INI_FILE | grep ^pretty= | sed -u 's/pretty=//g'`

#Initialize LASTSHOW array
for GN_REPO in $GN_REPOS; do
  if [[ -d ~/.gitnotify/$GN_REPO ]] ; then
    cd ~/.gitnotify/$GN_REPO
    GN_LASTSHOW[$GN_REPO]=`git show --pretty=$GN_PRETTY`
  else
    echo Unable to locate ~/.gitnotify/$GN_REPO repository >> ~/.gitnotify/log
  fi
done

#Check for updates and notify when necessary
while true; do
  for GN_REPO in $GN_REPOS; do
    if [[ -d ~/.gitnotify/$GN_REPO ]]; then
      cd ~/.gitnotify/$GN_REPO
      git pull --all
      GN_GITSHOW=`git show --pretty=$GN_PRETTY`
      if [ "${GN_LASTSHOW[$GN_REPO]}" != "$GN_GITSHOW" ]; then
        notify-send -i gtk-dialog-info -t 300000 -- "Git Update - $GN_REPO" "$GN_GITSHOW"
      fi
      GN_LASTSHOW[$GN_REPO]=$GN_GITSHOW
    else
      echo Unable to locate ~/.gitnotify/$GN_REPO repository >> ~/.gitnotify/log
      #Only keep the last thirty logs
      tail -n 30 log > log
    fi
  done
  sleep $GN_DURATION
done
