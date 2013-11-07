#!/bin/bash
clear
echo "This is information provided by mysystem.sh, program starts now."

echo "Hello $USER"
echo

echo "Today's date is `date`, this is week `date + "%V"`. `"%V"`"
echo

echo "These users are currently connected:"
w | cut -d " " -f 1 - | grep -v USER | -u
echo

echo "This is `uname -s` running on a `uname -m` processor."
echo

echo "This is the uptime information:"
uptime
echo

echo "That's all folks!"


