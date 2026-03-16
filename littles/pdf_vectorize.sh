#!/bin/bash

# pdf_vectorize.sh — Clean scanned pages and convert to vector PDF
#
# Useful to clean the background noise from the scanned children books or
# similar stuff with simple graphics presented (compare forms or shapes).

set -e

# --- Usage --------------------------------------------------------------------

usage() {
  echo "Usage: $(basename "$0") input.pdf output.pdf [--cleanup]"
  echo ""
  echo "Cleans scanned pencil drawings (removes gray background, vectorizes lines)"
  echo "and produces a print-ready vector PDF."
  echo ""
  echo "Options:"
  echo "  --cleanup   Remove temporary working files after completion"
  echo ""
  echo "Required tools: gs, imagemagick, parallel, potrace, inkscape, poppler (pdfunite)"
  exit 1
}

[[ $# -lt 2 ]] && usage

INPUT="$1"
OUTPUT="$2"
CLEANUP=0
[[ "${3:-}" == "--cleanup" ]] && CLEANUP=1

# --- Checks -------------------------------------------------------------------

check_tool() {
  if ! command -v "$1" &>/dev/null; then
    echo "❌ Missing: $1 — install with: $2"
    MISSING=1
  else
    echo "✅ Found: $1"
  fi
}

echo "Checking required tools..."
MISSING=0
check_tool gs          "brew install ghostscript"
check_tool magick      "brew install imagemagick"
check_tool parallel    "brew install parallel"
check_tool potrace     "brew install potrace"
check_tool inkscape    "brew install inkscape"
check_tool pdfunite    "brew install poppler"

[[ $MISSING -eq 1 ]] && { echo ""; echo "Please install missing tools and try again."; exit 1; }

[[ ! -f "$INPUT" ]] && { echo "❌ Input file not found: $INPUT"; exit 1; }

# --- Work directory -----------------------------------------------------------

WORKDIR=$(mktemp -d)
echo ""
echo "Working in: $WORKDIR"

cleanup() {
  if [[ $CLEANUP -eq 1 ]]; then
    echo "Cleaning up temp files..."
    rm -rf "$WORKDIR"
  else
    echo ""
    echo "ℹ️  Temp files kept at: $WORKDIR"
    echo "   Remove manually with: rm -rf \"$WORKDIR\""
    echo ""
  fi
}
trap cleanup EXIT

# --- Pipeline -----------------------------------------------------------------

echo ""
echo "Step 1/4: Rasterizing PDF into PNGs..."
gs -dBATCH -dNOPAUSE -sDEVICE=png16m -r300 \
   -sOutputFile="$WORKDIR/page_%03d.png" "$INPUT"

echo ""
echo "Step 2/4: Cleaning and converting to 1-bit BMP..."
# -level 40%,80%  : remap gray tones (tune if needed)
# -threshold 50%  : convert to pure B&W
# -blur 0x1       : smooth pixel edges before vectorization (tune: 0x0.5 to 0x2)
ls "$WORKDIR"/page_*.png | parallel \
  "magick {} -colorspace Gray -level 40%,80% -threshold 50% -monochrome {.}.bmp && \
   magick {.}.bmp -blur 0x1 -threshold 50% {.}_blurred.bmp"

echo ""
echo "Step 3/4: Vectorizing with potrace..."
# --turdsize 10   : remove noise blobs smaller than N pixels
# --alphamax 1.5  : rounder corners / smoother curves
# --opttolerance 0.5 : higher = smoother, less detail (tune: 0.2 to 1.0)
ls "$WORKDIR"/*_blurred.bmp | parallel \
  "potrace --svg --turdsize 10 --alphamax 1.5 --opttolerance 0.5 --output {.}.svg {}"

echo ""
echo "Step 4/4: Rendering SVGs to PDF and merging..."
ls "$WORKDIR"/*_blurred.svg | parallel \
  "inkscape {} --export-filename={.}.pdf"

pdfunite "$WORKDIR"/*_blurred.pdf "$OUTPUT"

echo ""
echo "✅ Done: $OUTPUT"
