#!/bin/bash

while [[ $# -gt 0 ]]; do
  case $1 in
    -e|--epub_dir)
      EPUB_DIR="$2"
      shift # past argument
      shift # past value
      ;;
    -p|--pdf_dir)
      PDF_DIR="$2"
      shift # past argument
      shift # past value
      ;;
    --default)
      DEFAULT=YES
      shift # past argument
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

if [ -z "$EPUB_DIR" ]; then
	echo "epub_dir not set"
	exit 1
fi
if [ -z "$PDF_DIR" ]; then
	echo "pdf_dir not set"
	exit 1
fi

# find all epubs younger than 1 weeks
mapfile -d '' EPUB_ARRAY < <(find "$EPUB_DIR" -name *.epub -newermt $(date +%Y-%m-%d -d '7 day ago') -type f -print0)
mapfile -d '' PDF_ARRAY < <(find "$PDF_DIR" -type f -print0)
for EPUB in "${EPUB_ARRAY[@]}"
do
	PDF_FNAME=$(basename "${EPUB%.epub}.pdf")
	found=0
	for PDF in "${PDF_ARRAY[@]}"
	do
		[[ "$PDF_FNAME" == $(basename "$PDF") ]] && found=1
	done
	if [[ $found == 0 ]]; then
		echo "Converting to " "$PDF_FNAME"
		ebook-convert "$EPUB" "$PDF_DIR"/"$PDF_FNAME"
	else
		echo "Found pdf ""$PDF_FNAME"
	fi
done

# remove old pdfs: iterate pdfs and check if they are present in EPUB_ARRAY
# if they are not present in EPUB_ARRAY -> delete
for PDFENTRY in "${PDF_ARRAY[@]}"
do
	EPUB_FNAME=$(basename "${PDFENTRY%.pdf}.epub")
	found=0
	for EPUB in "${EPUB_ARRAY[@]}"
	do
		[[ "$EPUB_FNAME" == $(basename "$EPUB") ]] && found=1
	done
	echo "$EPUB_FNAME"
	echo "found: " $found
	if [[ $found == 0 ]]; then
		echo "Deleting " "$PDFENTRY"
		rm "$PDFENTRY"
	fi
done

# check if pdf is referenced, if not create files

