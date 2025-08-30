#!/usr/bin/env bash

echo ">>> Checking services that need to be restarted..."

sudo needrestart -r a
NEEDRESTART="$(sudo needrestart -r l)"

#if [[ "$NEEDRESTART" =~ "Services to be restarted" ]]; then
#  while read -ra line; do
#    if [[ $line[0] =~ 'NEEDRESTART-SVC' ]]; then
#      echo "Restarting: ${line[1]}";
#      sudo systemctl restart ${line[1]};
#    fi
#  done <<< `sudo needrestart -b`
#else
#  echo "No services to restart"
#fi

echo ">>> Checking deferred services that need to be restarted..."

if [[ "$NEEDRESTART" =~ "Service restarts being deferred" ]]; then
  while read -ra line; do
    if [[ $line[0] =~ 'NEEDRESTART-SVC' ]]; then
      if [[ ${line[1]} =~ ^user@[0-9]+\.service$ ]]; then
        echo "Skipping: ${line[1]}"
      else
        echo "Restarting: ${line[1]}"
        sudo systemctl restart ${line[1]}
      fi
    fi
  done <<< `sudo needrestart -b`
else
  echo
  echo "No deferred services to restart"
  echo
fi
