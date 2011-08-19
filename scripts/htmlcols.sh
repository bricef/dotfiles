#!/bin/bash


colors=$(grep -Eo "#[0-9a-fA-F]{6}" ~/.vim/colors/BusyBee.vim| sort | uniq)

echo "<table>"

for col in $colors; do
  echo "<tr><td>$col</td>"
  for col2 in $colors; do
    echo "<td style=\"padding-top:3px;padding-bottom:3px;\"><span style=\"font-weight:bold;background:$col;color:$col2\"> $col2</span> </td>"
  done
  echo "</tr>"
done

echo "</table>"
