#!/bin/bash

TEMPLATE_TEX=~/scripts/templates/template.tex
OUT_TEX=$(mktemp).tex

function markdown_to_pdf {
  <$1 pinc.py \
  | pandoc  --standalone --smart \
            --template=$TEMPLATE_TEX \
            -f markdown -t latex \
            - -o $OUT_TEX
#           --toc \

  texi2pdf --batch  --clean --output=$2 $OUT_TEX
}

set -x

if [ -r "$1" ]; then
  INPUT_MD=$1
  OUTPUT_PDF=${1%.*}.pdf
  markdown_to_pdf $INPUT_MD $OUTPUT_PDF
else
  echo "You must specify a file to process"
fi 

echo $OUT_TEX

set +x
