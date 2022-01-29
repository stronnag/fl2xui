#!/bin/bash

ENABLE_PDF_EXPORT=1 mkdocs build
BASE=fl2xui
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dBATCH -dColorImageResolution=150 -sOutputFile=../$BASE.pdf $BASE.pdf
rm -f  $BASE.pdf
