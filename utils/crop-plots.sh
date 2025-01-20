#!/bin/bash

# Directory containing the PDF files
PDF_DIR="plots"

# Loop through all PDF files in the directory
for pdf_file in "$PDF_DIR"/*.pdf; do
  # Crop the PDF file and overwrite the original file
  pdfcrop "$pdf_file" "$pdf_file"
done
