#!/bin/bash

TITLE=$(zenity --entry --text="New Title:")

if [ "$TITLE" ]; then
  wmctrl -r :ACTIVE: -N "$TITLE"
fi
