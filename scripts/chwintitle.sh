#!/bin/bash
wmctrl -r :ACTIVE: -N "$(zenity --entry --text="New Title:")"
